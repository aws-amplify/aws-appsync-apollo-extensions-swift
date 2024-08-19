//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

struct AppSyncRealTimeStartRequest: Encodable {
    let id: String
    let data: String
    let auth: [String: String]?

    enum CodingKeys: CodingKey {
        case type
        case id
        case payload
    }

    enum PayloadCodingKeys: CodingKey {
        case data
        case extensions
    }

    enum ExtensionsCodingKeys: CodingKey {
        case authorization
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("start", forKey: .type)
        try container.encode(id, forKey: .id)

        let payloadEncoder = container.superEncoder(forKey: .payload)
        var payloadContainer = payloadEncoder.container(keyedBy: PayloadCodingKeys.self)
        try payloadContainer.encode(data, forKey: .data)

        let extensionEncoder = payloadContainer.superEncoder(forKey: .extensions)
        var extensionContainer = extensionEncoder.container(keyedBy: ExtensionsCodingKeys.self)
        try extensionContainer.encodeIfPresent(auth, forKey: .authorization)
    }
}
