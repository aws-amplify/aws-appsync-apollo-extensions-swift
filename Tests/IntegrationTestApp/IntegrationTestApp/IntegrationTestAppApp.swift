//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSAppSyncApolloExtensions
import AWSCognitoAuthPlugin
import SwiftUI

@main
struct IntegrationTestAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    init() {
        Amplify.Logging.logLevel = .verbose
        AppSyncApolloLogger.logLevel = .verbose
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure(with: .amplifyOutputs)
        } catch {
            print("Failed to configure Amplify \(error)")
        }
    }
}
