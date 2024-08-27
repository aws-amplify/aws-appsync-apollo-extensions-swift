//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//


import XCTest
@testable import AWSAppSyncApolloExtensions

class PackageInfoTests: XCTestCase {

    /// user agent header has format of:
    /// UA/2.0 lang/swift/x.x(.x) os/[iOS, macOS, watchOS]/x.x(.x) lib/aws-appsync-apollo-extensions-swift/x.x.x
    func testUserAgentHasCorrectFormat() async throws {
        let pattern = "^UA/2\\.0 " +
            "lang/swift#\\d+\\.\\d+(?:\\.\\d+)? " +
            "os/(?:iOS|macOS|watchOS|tvOS)#\\d+\\.\\d+(?:\\.\\d+)? " +
            "lib/aws-appsync-apollo-extensions-swift#\\d+\\.\\d+\\.\\d+ " +
            "md/apollo#\\d+\\.\\d+\\.\\d+$"
        let regex = try NSRegularExpression(pattern: pattern)
        let userAgent = await PackageInfo.userAgent
        let matches = regex.numberOfMatches(in: userAgent, options: [], range: NSRange(location: 0, length: userAgent.utf8.count))
        XCTAssertTrue(matches > 0)
    }
}
