//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Apollo
import ApolloWebSocket

import AppSyncAPI
import AWSAppSyncApolloInterceptors
import AWSPluginsCore

import XCTest
@testable import IntegrationTestApp


final class APIKeyTests: IntegrationTestBase {

    func testConfigurationUsesHTTPS() {
        XCTAssertEqual(Network.shared.configuration.endpoint.scheme, "https")
    }

    func testAPIKeyApolloClientMutation() throws {
        let completed = expectation(description: "mutation completed")

        Network.shared.apolloAPIKey.perform(mutation: CreateTodoMutation(createTodoInput: .init())) { result in
            switch result {
            case .success(let graphQLResult):
                guard (graphQLResult.data?.createTodo) != nil else {
                    XCTFail("Missing created Todo")
                    return
                }
                if let errors = graphQLResult.errors {
                    XCTFail("Failed with errors \(errors)")
                }
                completed.fulfill()
            case .failure(let error):
                XCTFail("Could not create todo \(error)")
            }
        }

        wait(for: [completed], timeout: 10)
    }

    func testAPIKeyApolloClientThrowException() throws {
        let configuration = try AWSAppSyncConfiguration(with: .amplifyOutputs)
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        enum APIKeyError: Swift.Error {
            case failedToGetAPIKey
        }
        let authorizer = APIKeyAuthorizer {
            throw APIKeyError.failedToGetAPIKey
        }
        let interceptor = AppSyncInterceptor(authorizer)

        let interceptorProvider = DefaultPrependInterceptorProvider(interceptor: interceptor,
                                                                    store: store)
        let transport = RequestChainNetworkTransport(interceptorProvider: interceptorProvider,
                                                     endpointURL: configuration.endpoint)

        let client = ApolloClient(networkTransport: transport, store: store)

        let completedWithError = expectation(description: "mutation completed")

        client.perform(mutation: CreateTodoMutation(createTodoInput: .init())) { result in
            switch result {
            case .success(let graphQLResult):
                XCTFail("Created todo successfully with invalid token, response: \(graphQLResult)")

            case .failure(let error):
                guard case .failedToGetAPIKey = error as? APIKeyError else {
                    XCTFail("Unexpected error type")
                    return
                }
                completedWithError.fulfill()
            }
        }

        wait(for: [completedWithError], timeout: 10)
    }

    func testSubscriptionReceivesMutation() async throws {
        AppSyncApolloLogger.logLevel = .verbose
        let receivedMutation = expectation(description: "received mutation")

        let activeSubscription = Network.shared.apolloAPIKey.subscribe(subscription: OnCreateSubscription()) { result in
            switch result {
            case .success(let graphQLResult):
                guard (graphQLResult.data?.onCreateTodo) != nil else {
                    XCTFail("Missing created Todo")
                    return
                }
                if let errors = graphQLResult.errors {
                    XCTFail("Failed with errors \(errors)")
                }
                receivedMutation.fulfill()
            case .failure(let error):
                XCTFail("Could not create todo \(error)")
            }
        }

        try await Task.sleep(nanoseconds: 5 * 1_000_000_000) // 5 seconds

        let completed = expectation(description: "mutation completed")
        Network.shared.apolloAPIKey.perform(mutation: CreateTodoMutation(createTodoInput: .init())) { result in
            switch result {
            case .success(let graphQLResult):
                guard (graphQLResult.data?.createTodo) != nil else {
                    XCTFail("Missing created Todo")
                    return
                }
                if let errors = graphQLResult.errors {
                    XCTFail("Failed with errors \(errors)")
                }
                completed.fulfill()
            case .failure(let error):
                XCTFail("Could not create todo \(error)")
            }
        }

        await fulfillment(of: [completed, receivedMutation], timeout: 10)
        activeSubscription.cancel()
    }

    func testMaxSubscriptionReached() async throws {
        let configuration = try AWSAppSyncConfiguration(with: .amplifyOutputs)
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let authorizer = APIKeyAuthorizer(apiKey: configuration.apiKey ?? "")
        let interceptorProvider = DefaultPrependInterceptorProvider(interceptor:  AppSyncInterceptor(authorizer),
                                                                    store: store)
        let transport = RequestChainNetworkTransport(interceptorProvider: interceptorProvider,
                                                     endpointURL: configuration.endpoint)
        let websocket = AppSyncWebSocketClient(endpointURL: configuration.endpoint,
                                               authorizer: authorizer)
        let receivedConnection = expectation(description: "received connection")
        let receivedMaxSubscriptionsReachedError = expectation(description: "received MaxSubscriptionsReachedError")
        receivedConnection.expectedFulfillmentCount = 100
        let sink = websocket.publisher.sink { event in
            if case .string(let message) = event {
                if message.contains("start_ack") {
                    receivedConnection.fulfill()
                }
                if message.contains("MaxSubscriptionsReachedError") {
                    receivedMaxSubscriptionsReachedError.fulfill()
                }
            }
        }

        let webSocketTransport = WebSocketTransport(websocket: websocket)
        let splitTransport = SplitNetworkTransport(
            uploadingNetworkTransport: transport,
            webSocketNetworkTransport: webSocketTransport
        )
        let client = ApolloClient(networkTransport: splitTransport, store: store)

        for _ in 1...101 {
            _ = client.subscribe(subscription: OnCreateSubscription()) { _ in
            }
        }

        await fulfillment(of: [receivedConnection, receivedMaxSubscriptionsReachedError], timeout: 10)
    }

}
