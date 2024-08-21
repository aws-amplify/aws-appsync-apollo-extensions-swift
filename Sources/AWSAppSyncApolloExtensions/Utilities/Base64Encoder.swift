//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension StringProtocol {
    func base64EncodedString() throws -> String {
        let utf8Encoded = data(using: .utf8)
        guard let base64String = utf8Encoded?.base64EncodedString() else {
            return ""
        }
        return base64String
    }
}
