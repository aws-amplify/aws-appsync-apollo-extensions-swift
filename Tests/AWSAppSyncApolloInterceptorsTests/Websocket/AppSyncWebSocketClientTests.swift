//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSAppSyncApolloInterceptors
import XCTest

final class AppSyncWebSocketClientTests: XCTestCase {
    static let endpoint = URL(string: "https://abc.appsync-api.us-east-1.amazonaws.com/graphql")!
    static let urlRequest = URLRequest(url: endpoint)

    func testUseWebSocketProtocolScheme() throws {
        let websocket = AppSyncWebSocketClient(
            endpointURL: AppSyncWebSocketClientTests.endpoint,
            authorizer: APIKeyAuthorizer(apiKey: "apiKey"))

        XCTAssertEqual(websocket.request.url?.scheme, "wss")
    }
}
