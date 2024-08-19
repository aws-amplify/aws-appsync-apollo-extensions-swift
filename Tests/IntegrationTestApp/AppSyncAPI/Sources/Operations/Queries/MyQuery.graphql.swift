//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@_exported import ApolloAPI

public class MyQuery: GraphQLQuery {
  public static let operationName: String = "MyQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query MyQuery { listTodos { __typename items { __typename id updatedAt createdAt content owner } nextToken } }"#
    ))

  public init() {}

  public struct Data: AppSyncAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { self.__data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { AppSyncAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("listTodos", ListTodos?.self),
    ] }

    public var listTodos: ListTodos? { __data["listTodos"] }

    /// ListTodos
    ///
    /// Parent Type: `ModelTodoConnection`
    public struct ListTodos: AppSyncAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { self.__data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { AppSyncAPI.Objects.ModelTodoConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("items", [Item?].self),
        .field("nextToken", String?.self),
      ] }

      public var items: [Item?] { __data["items"] }
      public var nextToken: String? { __data["nextToken"] }

      /// ListTodos.Item
      ///
      /// Parent Type: `Todo`
      public struct Item: AppSyncAPI.SelectionSet {
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
}
