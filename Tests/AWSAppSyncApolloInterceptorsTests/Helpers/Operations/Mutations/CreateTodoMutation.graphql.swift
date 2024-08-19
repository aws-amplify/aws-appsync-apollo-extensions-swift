//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@_exported import ApolloAPI

public class CreateTodoMutation: GraphQLMutation {
  public static let operationName: String = "CreateTodo"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateTodo($createTodoInput: CreateTodoInput!) { createTodo(input: $createTodoInput) { __typename id updatedAt createdAt content owner } }"#
    ))

  public var createTodoInput: CreateTodoInput

  public init(createTodoInput: CreateTodoInput) {
    self.createTodoInput = createTodoInput
  }

  public var __variables: Variables? { ["createTodoInput": createTodoInput] }

  public struct Data: SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { self.__data = _dataDict }

    public static var __parentType: any ParentType { Objects.Mutation }
    public static var __selections: [Selection] { [
      .field("createTodo", CreateTodo?.self, arguments: ["input": .variable("createTodoInput")]),
    ] }

    public var createTodo: CreateTodo? { __data["createTodo"] }

    /// CreateTodo
    ///
    /// Parent Type: `Todo`
    public struct CreateTodo: SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { self.__data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { Objects.Todo }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", ID.self),
        .field("updatedAt", AWSDateTime.self),
        .field("createdAt", AWSDateTime.self),
        .field("content", String?.self),
        .field("owner", String?.self),
      ] }

      public var id: ID { __data["id"] }
      public var updatedAt: AWSDateTime { __data["updatedAt"] }
      public var createdAt: AWSDateTime { __data["createdAt"] }
      public var content: String? { __data["content"] }
      public var owner: String? { __data["owner"] }
    }
  }
}
