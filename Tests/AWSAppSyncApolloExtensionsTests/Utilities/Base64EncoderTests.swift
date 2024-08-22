//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//


import XCTest
@testable import AWSAppSyncApolloExtensions

class Base64EncoderTests: XCTestCase {

    func testBase64EncodedString_generateCorrectResult() throws {
        XCTAssertEqual(
            try "aws-appsync-apollo-extensions-swift".base64EncodedString(),
            "YXdzLWFwcHN5bmMtYXBvbGxvLWV4dGVuc2lvbnMtc3dpZnQ="
        )
    }
}
