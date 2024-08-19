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

    private static let jsonEncoder = JSONEncoder()

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
    private let endpointURL: URL

    /// The underlying URLSessionWebSocketTask
    private var connection: URLSessionWebSocketTask? {
        willSet {
            connection?.cancel(with: .goingAway, reason: nil)
        }
    }

    private let heartBeatsMonitor = PassthroughSubject<Void, Never>()

    /// Internal wriable WebSocketEvent data stream
    let subject = PassthroughSubject<AppSyncWebSocketEvent, Never>()
    var cancellable: AnyCancellable?
    var heartBeatMonitorCancellable: AnyCancellable?

    public var isConnected: Bool {
        connection?.state == .running
    }

    /// Interceptor for appending additional info before makeing the connection
    private var authorizer: AppSyncAuthorizer

    public convenience init(
        endpointURL: URL,
        authorizer: AppSyncAuthorizer,
        callbackQueue: DispatchQueue = .main
    ) {
        self.init(
            endpointURL: endpointURL,
            delegate: nil,
            callbackQueue: callbackQueue,
            authorizer: authorizer
        )
    }

    init(
        endpointURL: URL,
        delegate: ApolloWebSocket.WebSocketClientDelegate?,
        callbackQueue: DispatchQueue,
        authorizer: AppSyncAuthorizer
    ) {
        self.endpointURL = useWebSocketProtocolScheme(url: appSyncRealTimeEndpoint(endpointURL))
        self.request = URLRequest(url: self.endpointURL)
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

        subscribeToAppSyncResponse()

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
        heartBeatMonitorCancellable?.cancel()
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

            guard let startRequest = AppSyncRealTimeStartRequest(from: string) else {
                try await self.connection?.send(.string(string))
                return
            }

            var request = self.request
            request.httpBody = Data(startRequest.data.utf8)
            let headers = try await authorizer.getWebSocketSubscriptionPayload(request: request)

            let interceptedEvent = AppSyncRealTimeStartRequest(
                id: startRequest.id,
                data: startRequest.data,
                auth: headers
            )

            AppSyncApolloLogger.debug("[AppSyncWebSocketClient] Sending subscription message: \(startRequest.data)")

            guard let encodedjsonData = try? Self.jsonEncoder.encode(interceptedEvent),
                  let jsonString = String(data: encodedjsonData, encoding: .utf8)
            else {
                return
            }

            try await self.connection?.send(.string(jsonString))
        }
    }

    // MARK: - Deinit

    deinit {
        self.subject.send(completion: .finished)
        self.cancellable?.cancel()
        self.heartBeatMonitorCancellable?.cancel()
    }

    // MARK: - Connect Internals

    private func createWebSocketConnection() async throws -> URLSessionWebSocketTask {
        let host = appSyncApiEndpoint(endpointURL).host!
        var headers = ["host": host]

        let authHeaders = try await authorizer.getWebsocketConnectionHeaders(endpoint: endpointURL)
        for authHeader in authHeaders {
            headers[authHeader.key] = authHeader.value
        }

        let payload = "{}"

        let headerJsonData = try Self.jsonEncoder.encode(headers)
        var urlComponents = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false)

        urlComponents?.queryItems = [
            URLQueryItem(name: "header", value: headerJsonData.base64EncodedString()),
            URLQueryItem(name: "payload", value: try? payload.base64EncodedString())
        ]

        let decoratedURL = urlComponents?.url ?? endpointURL
        request.url = decoratedURL
        AppSyncApolloLogger.debug("[AppSyncWebSocketClient] connecting to server \(decoratedURL)")
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

    private func subscribeToAppSyncResponse() {
        self.cancellable = subject
            .handleEvents(receiveOutput: { [weak self] event in
                self?.onReceiveWebSocketEvent(event)
            })
            .sink { [weak self] event in
                switch event {
                case .string(let string):
                    guard let data = string.data(using: .utf8),
                          let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let type = response["type"] as? String
                    else {
                        break
                    }

                    switch type {
                    case "connection_ack":
                        AppSyncApolloLogger.debug("[AppSyncWebSocketClient] connection ack, starting heart beat monitoring...")
                        if let payload = response["payload"] as? [String: Any] {
                            self?.monitorHeartBeat(payload)
                        }
                    case "ka":
                        AppSyncApolloLogger.debug("[AppSyncWebSocketClient] keep alive")
                        self?.heartBeatsMonitor.send(())
                    default: break
                    }
                default: break
                }
        }
    }

    private func onReceiveWebSocketEvent(_ event: AppSyncWebSocketEvent) {
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

    private func monitorHeartBeat(_ connectionAck: [String: Any]) {
        let connectionTimeOutMs = (connectionAck["connectionTimeoutMs"] as? Int) ?? 300000
        AppSyncApolloLogger.debug("[AppSyncWebSocketClient] start monitoring heart beat with interval \(String(describing: connectionTimeOutMs))")

        self.heartBeatMonitorCancellable = heartBeatsMonitor.eraseToAnyPublisher()
            .debounce(for: .milliseconds(connectionTimeOutMs), scheduler: DispatchQueue.global(qos: .userInitiated))
            .first()
            .sink { [weak self] _ in
                AppSyncApolloLogger.debug("[AppSyncWebSocketClient] Keep alive timed out, disconnecting...")
                self?.disconnect(forceTimeout: nil)
            }

        self.heartBeatsMonitor.send(())
    }
}
