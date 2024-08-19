//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

// MARK: - URLSession delegate

extension AppSyncWebSocketClient: URLSessionWebSocketDelegate {

    enum AppSyncWebSocketClientError: Swift.Error {
        case connectionLost
        case connectionCancelled
    }

    public nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        AppSyncApolloLogger.debug("[AppSyncWebSocketClient] Websocket connected")
        subject.send(.connected)
    }

    public nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        AppSyncApolloLogger.debug("[AppSyncWebSocketClient] Websocket disconnected")
        subject.send(.disconnected(closeCode, reason.flatMap { String(data: $0, encoding: .utf8) }))
    }

    public nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Swift.Error?
    ) {
        guard let error else {
            AppSyncApolloLogger.debug("[AppSyncWebSocketClient] URLSession didComplete")
            return
        }

        AppSyncApolloLogger.debug("[AppSyncWebSocketClient] URLSession didCompleteWithError: \(error))")

        let nsError = error as NSError
        switch (nsError.domain, nsError.code) {
        case (NSURLErrorDomain.self, NSURLErrorNetworkConnectionLost), // connection lost
             (NSPOSIXErrorDomain.self, Int(ECONNABORTED)): // background to foreground
            subject.send(.error(AppSyncWebSocketClientError.connectionLost))
        case (NSURLErrorDomain.self, NSURLErrorCancelled):
            AppSyncApolloLogger.debug("Skipping NSURLErrorCancelled error")
            subject.send(.error(AppSyncWebSocketClientError.connectionCancelled))
        default:
            subject.send(.error(error))
        }
    }
}
