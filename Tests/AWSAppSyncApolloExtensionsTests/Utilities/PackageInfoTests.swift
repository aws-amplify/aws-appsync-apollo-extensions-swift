//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//


import XCTest
@testable import AWSAppSyncApolloExtensions

class PackageInfoTests: XCTestCase {

    @available(iOS 16.0, *)
    /// user agent header has format of:
    /// UA/2.0 lang/swift/x.x(.x) os/[iOS, macOS, watchOS]/x.x(.x) lib/aws-appsync-apollo-extensions-swift/x.x.x
    func testUserAgentHasCorrectFormat() async throws {
        let format = try Regex(
            "^UA/2\\.0 " +
            "lang/swift#\\d+\\.\\d+(?:\\.\\d+)? " +
            "os/(?:iOS|macOS|watchOS)#\\d+\\.\\d+(?:\\.\\d+)? " +
            "lib/aws-appsync-apollo-extensions-swift#\\d+\\.\\d+\\.\\d+ " +
            "md/apollo#\\d+\\.\\d+\\.\\d+$"
        )
        let userAgent = await PackageInfo.userAgent
        let matches = userAgent.ranges(of: format)
        XCTAssertTrue(!matches.isEmpty)
    }
}
