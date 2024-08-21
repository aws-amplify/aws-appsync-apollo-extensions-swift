//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@testable import AWSAppSyncApolloExtensions
import Combine
import XCTest

final class AppSyncWebSocketClientTests: XCTestCase {

    var localWebSocketServer: LocalWebSocketServer?

    override func setUp() async throws {
        localWebSocketServer = LocalWebSocketServer()
    }

    override func tearDown() async throws {
        localWebSocketServer?.stop()
    }

    func testUseWebSocketProtocolScheme() throws {
        let endpoint = URL(string: "https://abc.appsync-api.us-east-1.amazonaws.com/graphql")!

        let websocket = AppSyncWebSocketClient(
            endpointURL: endpoint,
            authorizer: APIKeyAuthorizer(apiKey: "apiKey"))

        XCTAssertEqual(websocket.request.url?.scheme, "wss")
    }

    func testConnect_withHttpScheme_didConnectedWithWs() async throws {
        guard let endpoint = try localWebSocketServer?.start() else {
            XCTFail("Local WebSocket server failed to start")
            return
        }
        let webSocketClient = AppSyncWebSocketClient(endpointURL: endpoint, authorizer: MockAppSyncAuthorizer())
        await verifyConnected(webSocketClient)
    }

    func testDisconnect_didDisconnectFromRemote() async throws {
        var cancellables = Set<AnyCancellable>()
        guard let endpoint = try localWebSocketServer?.start() else {
            XCTFail("Local WebSocket server failed to start")
            return
        }

        let disconnectedExpectation = expectation(description: "WebSocket did disconnect")

        let webSocketClient = AppSyncWebSocketClient(endpointURL: endpoint, authorizer: MockAppSyncAuthorizer())
        await verifyConnected(webSocketClient)

        webSocketClient.publisher
            .sink { event in
                switch event {
                case let .disconnected(closeCode, reason):
                    XCTAssertNil(reason)
                    XCTAssertEqual(closeCode, .goingAway)
                    disconnectedExpectation.fulfill()
                default:
                    XCTFail("No other type of event should be received")
                }
            }
            .store(in: &cancellables)
        webSocketClient.disconnect(forceTimeout: nil)
        await fulfillment(of: [disconnectedExpectation], timeout: 5)
    }

    func testWriteAndRead_withWebSocketClient_didBehavesCorrectly() async throws {
        var cancellables = Set<AnyCancellable>()
        guard let endpoint = try localWebSocketServer?.start() else {
            XCTFail("Local WebSocket server failed to start")
            return
        }

        let messageReceivedExpectation = expectation(description: "WebSocket could read/write text message")
        let sampleMessage = UUID().uuidString

        let webSocketClient = AppSyncWebSocketClient(endpointURL: endpoint, authorizer: MockAppSyncAuthorizer())
        await verifyConnected(webSocketClient)
        webSocketClient.publisher.sink { event in
            switch event {
            case .string(let message) where message == sampleMessage:
                messageReceivedExpectation.fulfill()
            default:
                XCTFail("No other type of event should be received")
            }
        }.store(in: &cancellables)

        webSocketClient.write(string: sampleMessage)

        await fulfillment(of: [messageReceivedExpectation], timeout: 5)
    }

    private func verifyConnected(
           _ webSocketClient: AppSyncWebSocketClient,
           autoConnectOnNetworkStatusChange: Bool = false,
           autoRetryOnConnectionFailure: Bool = false
   ) async {
       var cancellables = Set<AnyCancellable>()
       let connectedExpectation = expectation(description: "WebSocket did connect")
       webSocketClient.publisher.sink { event in
           switch event {
           case .connected:
               connectedExpectation.fulfill()
           default:
               XCTFail("No other type of event should be received")
           }
       }.store(in: &cancellables)

       webSocketClient.connect()
       await fulfillment(of: [connectedExpectation], timeout: 5)
   }
}

fileprivate class MockAppSyncAuthorizer: AppSyncAuthorizer {
    func getHttpAuthorizationHeaders(request: URLRequest) async throws -> [String : String] {
        return [:]
    }
    
    func getWebsocketConnectionHeaders(endpoint: URL) async throws -> [String : String] {
        return [:]
    }
    
    func getWebSocketSubscriptionPayload(request: URLRequest) async throws -> [String : String] {
        return [:]
    }
}
