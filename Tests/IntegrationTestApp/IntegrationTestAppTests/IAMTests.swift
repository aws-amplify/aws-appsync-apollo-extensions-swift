//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AppSyncAPI
import AWSAppSyncApolloExtensions
import XCTest
@testable import IntegrationTestApp

final class IAMTests: IntegrationTestBase {

    func testAuthTokenApolloClientMutation() async throws {
        try await signIn()
        let completed = expectation(description: "mutation completed")
        Network.shared.apolloIAM.perform(mutation: CreateTodoMutation(createTodoInput: .init())) { result in
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

    func testSubscriptionReceivesMutation() async throws {
        try await signIn()
        AppSyncApolloLogger.logLevel = .verbose
        let receivedMutation = expectation(description: "received mutation")

        let activeSubscription = Network.shared.apolloIAM.subscribe(subscription: OnCreateSubscription()) { result in
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
        Network.shared.apolloIAM.perform(mutation: CreateTodoMutation(createTodoInput: .init())) { result in
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
