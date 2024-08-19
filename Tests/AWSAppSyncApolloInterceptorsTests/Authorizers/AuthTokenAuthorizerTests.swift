//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSAppSyncApolloInterceptors
import XCTest

final class AuthTokenAuthorizerTests: XCTestCase {
    static let endpoint = URL(string: "https://abc.appsync-api.us-east-1.amazonaws.com/graphql")!
    static let urlRequest = URLRequest(url: endpoint)
    let authorizer = AuthTokenAuthorizer { "token" }

    func testGetHttpAuthorizationHeaders() async throws {
        let headers = try await authorizer.getHttpAuthorizationHeaders(request: APIKeyAuthorizerTests.urlRequest)
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers["authorization"], "token")
        XCTAssertTrue(headers["x-amz-date"] != nil)
    }

    func testGetWebsocketConnectionHeaders() async throws {
        let headers = try await authorizer.getWebsocketConnectionHeaders(endpoint: APIKeyAuthorizerTests.endpoint)

        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(headers["authorization"], "token")
    }

    func testGetWebSocketSubscriptionPayload() async throws {
        let headers = try await authorizer.getWebSocketSubscriptionPayload(request: APIKeyAuthorizerTests.urlRequest)

        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(headers["authorization"], "token")
    }
}
