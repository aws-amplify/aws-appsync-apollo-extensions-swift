//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import ApolloAPI
import Foundation

struct AppSyncRealTimeStartRequest {
    private static let jsonDecoder = JSONDecoder()

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
}

extension AppSyncRealTimeStartRequest: Codable {

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

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard try values.decode(String.self, forKey: .type) == "start" else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [CodingKeys.type],
                debugDescription: "Unsupported AppSync request type"
            ))
        }

        id = try values.decode(String.self, forKey: .id)
        let payloadDecoder = try values.superDecoder(forKey: .payload)
        let payloadValues = try payloadDecoder.container(keyedBy: PayloadCodingKeys.self)
        data = try payloadValues.decode(String.self, forKey: .data)

        let extensionDecoder = try payloadValues.superDecoder(forKey: .extensions)
        let extensionValues = try? extensionDecoder.container(keyedBy: ExtensionsCodingKeys.self)
        auth = try extensionValues?.decodeIfPresent([String: String].self, forKey: .authorization)
    }
}

extension AppSyncRealTimeStartRequest {
    init?(from query: String) {
        guard let data = query.data(using: .utf8),
              var json = try? JSONSerialization.jsonObject(with: data) as? JSONObject,
              let type = json["type"] as? String
        else {
            return nil
        }

        if type == "start" { // inject "data" back to payload
            var dataDict = [String: Any]()
            var payload = json["payload"] as? JSONObject
            if let query = payload?["query"] {
                dataDict["query"] = query
            }

            if let variables = payload?["variables"] {
                dataDict["variables"] = variables
            }

            if !dataDict.isEmpty,
               let jsonData = try? JSONSerialization.data(withJSONObject: dataDict)
            {
                payload?["data"] = String(decoding: jsonData, as: UTF8.self)
            }

            if let payload {
                json["payload"] = payload
            }
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: json),
           let request = try? Self.jsonDecoder.decode(AppSyncRealTimeStartRequest.self, from: jsonData)
        {
            self = request
        } else {
            return nil
        }
    }
}
