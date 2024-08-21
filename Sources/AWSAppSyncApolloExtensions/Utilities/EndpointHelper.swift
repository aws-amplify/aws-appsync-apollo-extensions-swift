//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

func appSyncApiEndpoint(_ url: URL) -> URL {
    guard let host = url.host else {
        return url
    }

    guard host.hasSuffix("amazonaws.com") else {
        if url.lastPathComponent == "realtime" {
            return url.deletingLastPathComponent()
        }
        return url
    }

    guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        return url
    }

    urlComponents.host = host.replacingOccurrences(of: "appsync-realtime-api", with: "appsync-api")
    guard let apiUrl = urlComponents.url else {
        return url
    }
    return apiUrl
}

func appSyncRealTimeEndpoint(_ url: URL) -> URL {
    guard let host = url.host else {
        return url
    }

    guard host.hasSuffix("amazonaws.com") else {
        return url.appendingPathComponent("realtime")
    }

    guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        return url
    }

    urlComponents.host = host.replacingOccurrences(of: "appsync-api", with: "appsync-realtime-api")
    guard let realTimeUrl = urlComponents.url else {
        return url
    }

    return realTimeUrl
}

func useWebSocketProtocolScheme(url: URL) -> URL {
    guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        return url
    }
    if urlComponents.scheme == "ws" || urlComponents.scheme == "wss" {
        return url
    }
    urlComponents.scheme = urlComponents.scheme == "http" ? "ws" : "wss"
    return urlComponents.url ?? url
}
