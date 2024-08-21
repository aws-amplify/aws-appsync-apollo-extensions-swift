//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Apollo
import XCTest
@testable import AWSAppSyncApolloExtensions

final class DefaultPrependInterceptorProviderTests: XCTestCase {

    func testPrependToFrontOfInterceptors() async throws {
        let store = ApolloStore()
        let interceptor = AppSyncInterceptor(APIKeyAuthorizer(apiKey: "A"))
        let interceptorProvider = DefaultPrependInterceptorProvider(
            interceptor: interceptor,
            store: store)
        var interceptors: [any ApolloInterceptor] = [AppSyncInterceptor(APIKeyAuthorizer(apiKey: "B"))]
        interceptorProvider.addInterceptorToBeginning(&interceptors)
        XCTAssertEqual(interceptors.count, 2)
        let apiKey1 = try await ((interceptors[0] as? AppSyncInterceptor)?.authorizer as? APIKeyAuthorizer)?.fetchAPIKey()
        XCTAssertEqual(apiKey1, "A")
        let apiKey2 = try await ((interceptors[1] as? AppSyncInterceptor)?.authorizer as? APIKeyAuthorizer)?.fetchAPIKey()
        XCTAssertEqual(apiKey2, "B")
    }
}
