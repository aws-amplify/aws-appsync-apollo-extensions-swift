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

    //    iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *
    static func error(_ log: String) {
        // Always logged, no conditional check needed
        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            os_log("%@", type: .error, log)
        } else {
            NSLog("%@", log)
        }
    }

    static func error(_ error: Error) {
        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            os_log("%@", type: .error, error.localizedDescription)
        } else {
            NSLog("%@", error.localizedDescription)
        }
    }

    static func warn(_ log: String) {
        guard logLevel.rawValue >= LogLevel.warn.rawValue else {
            return
        }

        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            os_log("%@", type: .info, log)
        } else {
            NSLog("%@", log)
        }
    }

    static func info(_ log: String) {
        guard logLevel.rawValue >= LogLevel.info.rawValue else {
            return
        }

        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            os_log("%@", type: .info, log)
        } else {
            NSLog("%@", log)
        }
    }

    static func debug(_ log: String) {
        guard logLevel.rawValue >= LogLevel.debug.rawValue else {
            return
        }

        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            os_log("%@", type: .debug, log)
        } else {
            NSLog("%@", log)
        }
    }

    static func verbose(_ log: String) {
        guard logLevel.rawValue >= LogLevel.verbose.rawValue else {
            return
        }

        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            os_log("%@", type: .debug, log)
        } else {
            NSLog("%@", log)
        }
    }
}
