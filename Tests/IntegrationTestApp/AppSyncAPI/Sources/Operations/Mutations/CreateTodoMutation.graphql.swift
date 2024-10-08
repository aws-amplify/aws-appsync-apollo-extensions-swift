// @generated
// This file was automatically generated and should not be edited.

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

  public struct Data: AppSyncAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { AppSyncAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createTodo", CreateTodo?.self, arguments: ["input": .variable("createTodoInput")]),
    ] }

    public var createTodo: CreateTodo? { __data["createTodo"] }

    /// CreateTodo
    ///
    /// Parent Type: `Todo`
    public struct CreateTodo: AppSyncAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

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
