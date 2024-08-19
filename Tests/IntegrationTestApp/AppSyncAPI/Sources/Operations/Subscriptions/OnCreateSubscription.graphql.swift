//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@_exported import ApolloAPI

public class OnCreateSubscription: GraphQLSubscription {
  public static let operationName: String = "onCreateSubscription"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"subscription onCreateSubscription { onCreateTodo { __typename id updatedAt createdAt content owner } }"#
    ))

  public init() {}

  public struct Data: AppSyncAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { self.__data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { AppSyncAPI.Objects.Subscription }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("onCreateTodo", OnCreateTodo?.self),
    ] }

    public var onCreateTodo: OnCreateTodo? { __data["onCreateTodo"] }

    /// OnCreateTodo
    ///
    /// Parent Type: `Todo`
    public struct OnCreateTodo: AppSyncAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { self.__data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { AppSyncAPI.Objects.Todo }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", AppSyncAPI.ID.self),
        .field("updatedAt", AppSyncAPI.AWSDateTime.self),
        .field("createdAt", AppSyncAPI.AWSDateTime.self),
        .field("content", String?.self),
        .field("owner", String?.self),
      ] }

      public var id: AppSyncAPI.ID { __data["id"] }
      public var updatedAt: AppSyncAPI.AWSDateTime { __data["updatedAt"] }
      public var createdAt: AppSyncAPI.AWSDateTime { __data["createdAt"] }
      public var content: String? { __data["content"] }
      public var owner: String? { __data["owner"] }
    }
  }
}
