//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Apollo
import ApolloAPI
import Foundation

public class AppSyncInterceptor: ApolloInterceptor {
    public var id: String = UUID().uuidString

    let authorizer: AppSyncAuthorizer
    public init(_ authorizer: AppSyncAuthorizer) {
        self.authorizer = authorizer

    }

    public func interceptAsync<Operation>(chain: Apollo.RequestChain,
                                          request: Apollo.HTTPRequest<Operation>,
                                          response: Apollo.HTTPResponse<Operation>?,
                                          completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void) where Operation: ApolloAPI.GraphQLOperation
    {
        Task {
            do {
                try await retrieveHeadersAndAddToRequest(request)
                chain.proceedAsync(
                    request: request,
                    response: response,
                    interceptor: self,
                    completion: completion)
            } catch {
                chain.handleErrorAsync(error, request: request, response: response, completion: completion)
            }
        }
    }

    func retrieveHeadersAndAddToRequest<Operation>(_ request: Apollo.HTTPRequest<Operation>) async throws {
        let headers = try await authorizer.getHttpAuthorizationHeaders(request: request.toURLRequest())
        for header in headers {
            request.addHeader(name: header.key, value: header.value)
        }
    }
}
