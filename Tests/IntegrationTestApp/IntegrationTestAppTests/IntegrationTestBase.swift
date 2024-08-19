//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSAppSyncApolloInterceptors
import XCTest

class IntegrationTestBase: XCTestCase {
    override func setUp() async throws {
        AppSyncApolloLogger.logLevel = .verbose
    }
    func signIn() async throws {
        let session = try await Amplify.Auth.fetchAuthSession()
        guard !session.isSignedIn else {
            return
        }

        // Sign in user either dynamically or pull from credentials file.
    }
}
