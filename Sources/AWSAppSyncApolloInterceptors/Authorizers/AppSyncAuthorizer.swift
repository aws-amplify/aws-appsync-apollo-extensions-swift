//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol AppSyncAuthorizer {
    func getHttpAuthorizationHeaders(request: URLRequest) async throws -> [String: String]

    func getWebsocketConnectionHeaders(endpoint: URL) async throws -> [String: String]

    func getWebSocketSubscriptionPayload(request: URLRequest) async throws -> [String: String]
}
