//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Apollo
import ApolloAPI
import Foundation

public class IAMAuthorizer: AppSyncAuthorizer {

    let signRequest: (_ urlRequest: URLRequest) async throws -> URLRequest
    public init(signRequest: @escaping (URLRequest) async throws -> URLRequest) {
        self.signRequest = signRequest
    }

    public func getHttpAuthorizationHeaders(request: URLRequest) async throws -> [String: String] {
        try await signRequest(request).allHTTPHeaderFields ?? [:]
    }

    public func getWebsocketConnectionHeaders(endpoint: URL) async throws -> [String: String] {
        let connectUrl = appSyncApiEndpoint(endpoint).appendingPathComponent("connect")

        let urlRequest = createURLRequest(url: connectUrl, httpBody: Data("{}".utf8))

        let signedRequest = try await signRequest(urlRequest)
        return signedRequest.allHTTPHeaderFields ?? [:]
    }

    public func getWebSocketSubscriptionPayload(request: URLRequest) async throws -> [String: String] {
        let appSyncUrl = appSyncApiEndpoint(request.url!)

        // remove query parameters set during connection.
        var components = URLComponents(url: appSyncUrl, resolvingAgainstBaseURL: false)!
        components.query = nil

        let urlRequest = createURLRequest(url: components.url!, httpBody: request.httpBody ?? Data())

        let signedRequest = try await signRequest(urlRequest)

        return signedRequest.allHTTPHeaderFields ?? [:]
    }

    func createURLRequest(url: URL, httpBody: Data) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json, text/javascript", forHTTPHeaderField: "accept")
        urlRequest.setValue("amz-1.0", forHTTPHeaderField: "content-encoding")
        urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

        urlRequest.httpBody = httpBody
        return urlRequest
    }
}
