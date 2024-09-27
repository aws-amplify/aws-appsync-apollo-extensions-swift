//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//


import Foundation
import Apollo
#if canImport(WatchKit)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#elseif canImport(IOKit)
import IOKit
#endif
#if canImport(AppKit)
import AppKit
#endif

class PackageInfo {

    private static let version = "1.0.2"

    @MainActor
    private static var os: (name: String, version: String) = {
#if canImport(WatchKit)
        let device = WKInterfaceDevice.current()
        return (name: device.systemName, version: device.systemVersion)
#elseif canImport(UIKit)
        let device = UIDevice.current
        return (name: device.systemName, version: device.systemVersion)
#else
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        return (name: "macOS",
                version: "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)")
#endif
    }()

    private static var swiftVersion: String = {
#if swift(>=7.0)
        return "unknown"
#elseif swift(>=6.0)
        return "6.x"
#elseif swift(>=5.10)
        return "5.10"
#elseif swift(>=5.9)
        return "5.9"
#else
        return "unknown"
#endif
    }()

    static var userAgent: String {
        get async {
            let (name, version) = await Self.os
            let compilerInfo = "lang/swift#\(swiftVersion)"
            let osInfo = "os/\(name)#\(version)"
            let libInfo = "lib/aws-appsync-apollo-extensions-swift#\(Self.version)"
            let dependenciesInfo = "md/apollo-ios#\(Constants.ApolloVersion)"

            return "UA/2.0 \(compilerInfo) \(osInfo) \(libInfo) \(dependenciesInfo)"
        }
    }

}
