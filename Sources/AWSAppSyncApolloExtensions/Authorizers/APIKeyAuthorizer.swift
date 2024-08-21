//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Apollo
import ApolloAPI
import Foundation

public class APIKeyAuthorizer: AppSyncAuthorizer {

    let fetchAPIKey: () async throws -> String
    static let apiKeyHeaderName = "x-api-key"
    static let amzDateHeaderName = "x-amz-date"
    static let AWSDateISO8601DateFormat2 = "yyyyMMdd'T'HHmmss'Z'"

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = APIKeyAuthorizer.AWSDateISO8601DateFormat2
        return formatter
    }()

    public init(apiKey: String) {
        self.fetchAPIKey = {
            apiKey
        }
    }
    public init(fetchAPIKey: @escaping () async throws -> String) {
        self.fetchAPIKey = fetchAPIKey
    }

    public func getHttpAuthorizationHeaders(request: URLRequest) async throws -> [String: String] {
        let apiKey = try await fetchAPIKey()
        return [APIKeyAuthorizer.apiKeyHeaderName: apiKey]
    }

    public func getWebsocketConnectionHeaders(endpoint: URL) async throws -> [String: String] {
        try await getWebsocketHeaders()
    }

    public func getWebSocketSubscriptionPayload(request: URLRequest) async throws -> [String: String] {
        try await getWebsocketHeaders()
    }

    private func getWebsocketHeaders() async throws -> [String: String] {
        let apiKey = try await fetchAPIKey()
        let date = formatter.string(from: Date())
        return [APIKeyAuthorizer.apiKeyHeaderName: apiKey,
                APIKeyAuthorizer.amzDateHeaderName: date]
    }
}
