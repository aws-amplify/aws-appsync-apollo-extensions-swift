//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import os

public enum AppSyncApolloLogger {

    public enum LogLevel: Int {
        case error
        case warn
        case info
        case debug
        case verbose
    }

    static let lock: NSLocking = NSLock()

    static var _logLevel = LogLevel.error // swiftlint:disable:this identifier_name

    public static var logLevel: LogLevel {
        get {
            lock.lock()
            defer {
                lock.unlock()
            }

            return _logLevel
        }
        set {
            lock.lock()
            defer {
                lock.unlock()
            }

            _logLevel = newValue
        }
    }

    static func error(_ log: String) {
        os_log("%@", type: .error, log)
    }

    static func error(_ error: Error) {
        os_log("%@", type: .error, error.localizedDescription)
    }

    static func warn(_ log: String) {
        guard logLevel.rawValue >= LogLevel.warn.rawValue else {
            return
        }

        os_log("%@", type: .info, log)
    }

    static func info(_ log: String) {
        guard logLevel.rawValue >= LogLevel.info.rawValue else {
            return
        }

        os_log("%@", type: .info, log)
    }

    static func debug(_ log: String) {
        guard logLevel.rawValue >= LogLevel.debug.rawValue else {
            return
        }

        os_log("%@", type: .debug, log)
    }

    static func verbose(_ log: String) {
        guard logLevel.rawValue >= LogLevel.verbose.rawValue else {
            return
        }

        os_log("%@", type: .debug, log)
    }
}
