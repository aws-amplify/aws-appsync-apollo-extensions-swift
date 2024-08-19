//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import ApolloAPI

public enum SchemaConfiguration: ApolloAPI.SchemaConfiguration {
  public static func cacheKeyInfo(for type: ApolloAPI.Object, object: ApolloAPI.ObjectData) -> CacheKeyInfo? {
    // Implement this function to configure cache key resolution for your schema types.
    return nil
  }
}
