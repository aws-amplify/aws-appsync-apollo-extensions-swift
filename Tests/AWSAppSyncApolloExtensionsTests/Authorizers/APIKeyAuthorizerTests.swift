//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSAppSyncApolloExtensions
import XCTest

final class APIKeyAuthorizerTests: XCTestCase {

    let authorizer = APIKeyAuthorizer(apiKey: "apiKey")
    static let endpoint = URL(string: "https://abc.appsync-api.us-east-1.amazonaws.com/graphql")!
    static let urlRequest = URLRequest(url: endpoint)

    func testGetHttpAuthorizationHeaders() async throws {

        let headers = try await authorizer.getHttpAuthorizationHeaders(request: APIKeyAuthorizerTests.urlRequest)

        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(headers["x-api-key"], "apiKey")
    }

    func testGetWebsocketConnectionHeaders() async throws {
        let headers = try await authorizer.getWebsocketConnectionHeaders(endpoint: APIKeyAuthorizerTests.endpoint)

        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers["x-api-key"], "apiKey")
        XCTAssertTrue(headers["x-amz-date"] != nil)
    }

    func testGetWebSocketSubscriptionPayload() async throws {
        let headers = try await authorizer.getWebSocketSubscriptionPayload(request: APIKeyAuthorizerTests.urlRequest)

        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers["x-api-key"], "apiKey")
        XCTAssertTrue(headers["x-amz-date"] != nil)
    }
}
