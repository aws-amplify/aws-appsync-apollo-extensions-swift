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


final class AuthTokenTests: IntegrationTestBase {

    func testAuthTokenApolloClientMutation() async throws {
        try await signIn()
        let completed = expectation(description: "mutation completed")
        Network.shared.apolloCUP.perform(mutation: CreateTodoMutation(createTodoInput: .init())) { result in
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

        await fulfillment(of: [completed], timeout: 10)
    }

    func testAuthTokenApolloClientMutation_InvalidToken_Mutation() async throws {
        let apolloCUPInvalidToken: ApolloClient = {
            let configuration = try! AWSAppSyncConfiguration(with: .amplifyOutputs)
            let store = ApolloStore(cache: InMemoryNormalizedCache())

            let authorizer = AuthTokenAuthorizer {
                "invalidToken"
            }
            let interceptorProvider = DefaultPrependInterceptorProvider(interceptor:  AppSyncInterceptor(authorizer),
                                                                        store: store)
            let transport = RequestChainNetworkTransport(interceptorProvider: interceptorProvider,
                                                         endpointURL: configuration.endpoint)
            return ApolloClient(networkTransport: transport, store: store)
        }()

        let completedWithError = expectation(description: "mutation completed with error")
        apolloCUPInvalidToken.perform(mutation: CreateTodoMutation(createTodoInput: .init())) { result in
            switch result {
            case .success(let graphQLResult):
                XCTFail("Created todo successfully with invalid token, response: \(graphQLResult)")
            case .failure:
                completedWithError.fulfill()
            }
        }

        await fulfillment(of: [completedWithError], timeout: 10)
    }

    func testAuthTokenApolloClientMutation_InvalidToken_Subscription() async throws {
        let configuration = try! AWSAppSyncConfiguration(with: .amplifyOutputs)
        let store = ApolloStore(cache: InMemoryNormalizedCache())

        let authorizer = AuthTokenAuthorizer {
            "invalidToken"
        }
        let interceptorProvider = DefaultPrependInterceptorProvider(interceptor:  AppSyncInterceptor(authorizer),
                                                                    store: store)
        let transport = RequestChainNetworkTransport(interceptorProvider: interceptorProvider,
                                                     endpointURL: configuration.endpoint)
        let websocket = AppSyncWebSocketClient(endpointURL: configuration.endpoint,
                                               authorizer: authorizer)
        let receivedDisconnectError = expectation(description: "received disconnect")
        receivedDisconnectError.assertForOverFulfill = false
        let sink = websocket.publisher.sink { event in
            if case .error(let error) = event, error.localizedDescription.contains("Socket is not connected") {
                receivedDisconnectError.fulfill()
            }
        }
        let webSocketTransport = WebSocketTransport(websocket: websocket)
        let splitTransport = SplitNetworkTransport(
            uploadingNetworkTransport: transport,
            webSocketNetworkTransport: webSocketTransport
        )
        let apolloCUPInvalidToken = ApolloClient(networkTransport: splitTransport, store: store)

        await fulfillment(of: [receivedDisconnectError], timeout: 10)
    }

    func testSubscriptionReceivesMutation() async throws {
        try await signIn()

        let receivedMutation = expectation(description: "received mutation")

        let activeSubscription = Network.shared.apolloCUP.subscribe(subscription: OnCreateSubscription()) { result in
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
        Network.shared.apolloCUP.perform(mutation: CreateTodoMutation(createTodoInput: .init())) { result in
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
}
