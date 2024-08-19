//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Apollo
import XCTest
@testable import AWSAppSyncApolloInterceptors

final class AppSyncInterceptorTests: XCTestCase {

    static let endpoint = URL(string: "https://abc.appsync-api.us-east-1.amazonaws.com/graphql")!

    func testAddHeadersToRequest() async throws {
        let interceptor = AppSyncInterceptor(APIKeyAuthorizer(apiKey: "apikey"))
        let request = Apollo.HTTPRequest<CreateTodoMutation>(
            graphQLEndpoint: AppSyncInterceptorTests.endpoint,
            operation: CreateTodoMutation(createTodoInput: .init(.init())),
            contentType: "",
            clientName: "",
            clientVersion: "",
            additionalHeaders: [:])

        XCTAssertEqual(request.additionalHeaders.count, 5)
        try await interceptor.retrieveHeadersAndAddToRequest(request)
        XCTAssertEqual(request.additionalHeaders.count, 6)
        XCTAssertEqual(request.additionalHeaders["x-api-key"], "apikey")
    }
}
