//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Apollo
import ApolloAPI
import Foundation

public class AuthTokenAuthorizer: AppSyncAuthorizer {

    let fetchLatestAuthToken: () async throws -> String

    static let authorizationHeaderName = "authorization"
    static let amzDateHeaderName = "x-amz-date"
    static let AWSDateISO8601DateFormat2 = "yyyyMMdd'T'HHmmss'Z'"

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = AuthTokenAuthorizer.AWSDateISO8601DateFormat2
        return formatter
    }()

    public init(fetchLatestAuthToken: @escaping () async throws -> String) {
        self.fetchLatestAuthToken = fetchLatestAuthToken
    }

    public func getHttpAuthorizationHeaders(request: URLRequest) async throws -> [String: String] {
        let date = formatter.string(from: Date())
        let token = try await fetchLatestAuthToken()
        AppSyncApolloLogger.debug("Received token \(token.masked())")
        return [AuthTokenAuthorizer.amzDateHeaderName: date,
                AuthTokenAuthorizer.authorizationHeaderName: token]
    }

    public func getWebsocketConnectionHeaders(endpoint: URL) async throws -> [String: String] {
        try await getWebSocketHeaders()
    }

    public func getWebSocketSubscriptionPayload(request: URLRequest) async throws -> [String: String] {
        try await getWebSocketHeaders()
    }

    func getWebSocketHeaders() async throws -> [String: String] {
        let token = try await fetchLatestAuthToken()
        AppSyncApolloLogger.debug("Received token \(token.masked())")
        return [AuthTokenAuthorizer.authorizationHeaderName: token]
    }
}
