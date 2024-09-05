//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSAppSyncApolloExtensions
import XCTest

class IntegrationTestBase: XCTestCase {
    let username = "integTest\(UUID().uuidString)"
    let password = "P123@\(UUID().uuidString)"
    var defaultTestEmail = "test-\(UUID().uuidString)@amazon.com"
    override func setUp() async throws {
        AppSyncApolloLogger.logLevel = .verbose
    }
    func signIn() async throws {
        let session = try await Amplify.Auth.fetchAuthSession()
        guard !session.isSignedIn else {
            return
        }

        _ = try await AuthSignInHelper.registerAndSignInUser(username: username, password: password, email: defaultTestEmail) 
    }
}
