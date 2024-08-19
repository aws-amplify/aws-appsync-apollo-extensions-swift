//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSAppSyncApolloInterceptors
import XCTest

final class IAMAuthorizerTests: XCTestCase {

    static let endpoint = URL(string: "https://abc.appsync-api.us-east-1.amazonaws.com/graphql")!
    static let urlRequest = URLRequest(url: endpoint)
    let authorizer = IAMAuthorizer { urlRequest in
        urlRequest
    }

    func testGetHttpAuthorizationHeaders() async throws {
        let headers = try await authorizer.getHttpAuthorizationHeaders(request: APIKeyAuthorizerTests.urlRequest)
        XCTAssertEqual(headers.count, 0)
    }

    func testGetWebsocketConnectionHeaders() async throws {
        let headers = try await authorizer.getWebsocketConnectionHeaders(endpoint: APIKeyAuthorizerTests.endpoint)

        XCTAssertEqual(headers.count, 3)
        XCTAssertEqual(headers["Accept"], "application/json, text/javascript")
        XCTAssertEqual(headers["Content-Encoding"], "amz-1.0")
        XCTAssertEqual(headers["Content-Type"], "application/json; charset=UTF-8")
    }

    func testGetWebSocketSubscriptionPayload() async throws {
        let headers = try await authorizer.getWebSocketSubscriptionPayload(request: APIKeyAuthorizerTests.urlRequest)

        XCTAssertEqual(headers.count, 3)
        XCTAssertEqual(headers["Accept"], "application/json, text/javascript")
        XCTAssertEqual(headers["Content-Encoding"], "amz-1.0")
        XCTAssertEqual(headers["Content-Type"], "application/json; charset=UTF-8")
    }
}
