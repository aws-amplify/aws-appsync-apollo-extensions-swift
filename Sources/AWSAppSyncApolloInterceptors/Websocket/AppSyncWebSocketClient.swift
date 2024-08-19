//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Apollo
import ApolloAPI
import ApolloWebSocket
import Combine
import Foundation

public class AppSyncWebSocketClient: NSObject, ApolloWebSocket.WebSocketClient, URLSessionDelegate {

    // MARK: - ApolloWebSocket.WebSocketClient

    public var request: URLRequest
    public var delegate: ApolloWebSocket.WebSocketClientDelegate?
    public var callbackQueue: DispatchQueue

    // MARK: - Public

    public var publisher: AnyPublisher<AppSyncWebSocketEvent, Never> {
        return subject.eraseToAnyPublisher()
    }

    // MARK: - Internal

    private let taskQueue: TaskQueue<Void>

    /// The underlying URLSessionWebSocketTask
    private var connection: URLSessionWebSocketTask? {
        willSet {
            connection?.cancel(with: .goingAway, reason: nil)
        }
    }

    /// Internal wriable WebSocketEvent data stream
    let subject = PassthroughSubject<AppSyncWebSocketEvent, Never>()
    var cancellable: AnyCancellable?

    public var isConnected: Bool {
        connection?.state == .running
    }

    /// Interceptor for appending additional info before makeing the connection
    private var authorizer: AppSyncAuthorizer

    public convenience init(endpointURL: URL,
                            authorizer: AppSyncAuthorizer,
                            callbackQueue: DispatchQueue = .main)
    {
        self.init(endpointURL: endpointURL,
                  delegate: nil,
                  callbackQueue: callbackQueue,
                  authorizer: authorizer)
    }

    init(endpointURL: URL,
         delegate: ApolloWebSocket.WebSocketClientDelegate?,
         callbackQueue: DispatchQueue,
         authorizer: AppSyncAuthorizer)
    {
        let url = useWebSocketProtocolScheme(url: appSyncRealTimeEndpoint(endpointURL))
        self.request = URLRequest(url: url)
        self.delegate = delegate
        self.callbackQueue = callbackQueue
        self.authorizer = authorizer
        self.taskQueue = TaskQueue()
        request.setValue("graphql-ws", forHTTPHeaderField: "Sec-WebSocket-Protocol")
    }

    public func connect() {
        AppSyncApolloLogger.debug("Calling Connect")
        guard connection?.state != .running else {
            AppSyncApolloLogger.debug("[AppSyncWebSocketClient] WebSocket is already in connecting state")
            return
        }

        cancellable = subject.sink { completion in
            AppSyncApolloLogger.debug("Completed")
        } receiveValue: { [weak self] event in
            guard let self else { return }
            switch event {
            case .connected:
                callbackQueue.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.websocketDidConnect(socket: self)
                }
            case .data(let data):
                callbackQueue.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.websocketDidReceiveData(socket: self, data: data)
                }
            case .string(let string):
                callbackQueue.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.websocketDidReceiveMessage(socket: self, text: string)
                }
            case .disconnected(let closeCode, let string):
                callbackQueue.async { [weak self] in
                    guard let self = self else { return }
                    AppSyncApolloLogger.debug("Disconnected closeCode \(closeCode), string \(String(describing: string))")
                    self.delegate?.websocketDidDisconnect(socket: self, error: nil)
                }
            case .error(let error):
                callbackQueue.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.websocketDidDisconnect(socket: self, error: error)
                }
            }
        }
        Task {
            AppSyncApolloLogger.debug("[AppSyncWebSocketClient] Creating new connection and starting read")
            self.connection = try await createWebSocketConnection()
            // Perform reading from a WebSocket in a separate task recursively to avoid blocking the execution.
            Task { await self.startReadMessage() }
            self.connection?.resume()
        }
    }

    public func disconnect(forceTimeout: TimeInterval?) {
        AppSyncApolloLogger.debug("Calling Disconnect")
        guard connection?.state == .running else {
            AppSyncApolloLogger.debug("[AppSyncWebSocketClient] client should be in connected state to trigger disconnect")
            return
        }

        connection?.cancel(with: .goingAway, reason: nil)
    }

    public func write(ping: Data, completion: (() -> Void)?) {
        AppSyncApolloLogger.debug("Not called, not implemented.")
    }

    public func write(string: String) {
        taskQueue.async { [weak self] in
            guard let self else { return }
            guard self.isConnected else {
                AppSyncApolloLogger.debug("[AppSyncWebSocketClient] Attempting to write to a webSocket haven't been connected.")
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: string.data(using: .utf8)!) as? JSONObject,
                  let id = json["id"] as? String
            else {
                AppSyncApolloLogger.debug("[AppSyncWebSocketClient] Sending: \(string)")
                Task { try await self.connection?.send(.string(string)) }
                return
            }

            let type = json["type"] as? String
            let payload = json["payload"] as? JSONObject
            guard type == "start" else {
                AppSyncApolloLogger.debug("[AppSyncWebSocketClient] Sending: \(string)")
                Task { try await self.connection?.send(.string(string)) }
                return
            }

            guard let query = payload?["query"] else {
                AppSyncApolloLogger.debug("[AppSyncWebSocketClient] Sending: \(string)")
                Task { try await self.connection?.send(.string(string)) }
                return
            }

            var dataDict: [String: Any] = ["query": query]
            if let subVariables = payload?["variables"] {
                dataDict["variables"] = subVariables
            }

            let jsonData = try JSONSerialization.data(withJSONObject: dataDict)

            var request = self.request
            let strData = String(decoding: jsonData, as: UTF8.self)
            request.httpBody = Data(strData.utf8)
            let headers = try await authorizer.getWebSocketSubscriptionPayload(request: request)

            let interceptedEvent = AppSyncRealTimeStartRequest(
                id: id,
                data: strData,
                auth: headers)
            AppSyncApolloLogger.debug("[AppSyncWebSocketClient] Sending subscription message: \(interceptedEvent.data)")

            let jsonEncoder = JSONEncoder()
            let encodedjsonData = try! jsonEncoder.encode(interceptedEvent)
            guard let jsonString = String(data: encodedjsonData, encoding: .utf8) else {
                return
            }

            try await self.connection?.send(.string(jsonString))
        }
    }

    // MARK: - Deinit

    deinit {
        self.subject.send(completion: .finished)
        self.cancellable = nil
    }

    // MARK: - Connect Internals

    private func createWebSocketConnection() async throws -> URLSessionWebSocketTask {
        let url = request.url!
        let host = appSyncApiEndpoint(url).host!
        var headers = ["host": host]

        let authHeaders = try await authorizer.getWebsocketConnectionHeaders(endpoint: url)
        for authHeader in authHeaders {
            headers[authHeader.key] = authHeader.value
        }

        let payload = "{}"

        let jsonEncoder = JSONEncoder()
        let headerJsonData = try jsonEncoder.encode(headers)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)

        urlComponents?.queryItems = [
            URLQueryItem(name: "header", value: headerJsonData.base64EncodedString()),
            URLQueryItem(name: "payload", value: try? payload.base64EncodedString())
        ]

        let decoratedURL = urlComponents?.url ?? url
        request.url = decoratedURL

        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        return urlSession.webSocketTask(with: request)
    }

    /**
     Recusively read WebSocket data frames and publish to data stream.
     */
    private func startReadMessage() async {
        guard let connection = connection else {
            AppSyncApolloLogger.debug("[AppSyncWebSocketClient] WebSocket connection doesn't exist")
            return
        }
        if connection.state == .canceling || connection.state == .completed {
            AppSyncApolloLogger.debug("[AppSyncWebSocketClient] WebSocket connection state is \(connection.state). Failed to read websocket message")
            return
        }
        do {
            let message = try await connection.receive()
            AppSyncApolloLogger.debug("[AppSyncWebSocketClient] WebSocket received message: \(String(describing: message))")
            switch message {
            case .data(let data):
                subject.send(.data(data))
            case .string(let string):
                subject.send(.string(string))
            @unknown default:
                break
            }
        } catch {
            if connection.state == .running {
                subject.send(.error(error))
            } else {
                AppSyncApolloLogger.debug("[AppSyncWebSocketClient] read message failed with connection state \(connection.state), error \(error)")
            }
        }
        await startReadMessage()
    }
}
