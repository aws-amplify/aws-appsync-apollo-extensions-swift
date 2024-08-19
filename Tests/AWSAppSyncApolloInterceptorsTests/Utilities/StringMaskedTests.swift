//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import AWSAppSyncApolloInterceptors

final class StringMaskedTests: XCTestCase {

    func testMaskedRedacteSensitiveInformation() {
        let accessToken = "1234567890abcdef"
        let expectedMaskedToken = "12************ef"

        let maskedToken = accessToken.masked()

        XCTAssertEqual(maskedToken, expectedMaskedToken)
    }
}
