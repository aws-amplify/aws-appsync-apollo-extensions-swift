// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateTodoMutation: GraphQLMutation {
  public static let operationName: String = "UpdateTodo"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateTodo($updateTodoInput: UpdateTodoInput!) { updateTodo(input: $updateTodoInput) { __typename id updatedAt createdAt content owner } }"#
    ))

  public var updateTodoInput: UpdateTodoInput

  public init(updateTodoInput: UpdateTodoInput) {
    self.updateTodoInput = updateTodoInput
  }

  public var __variables: Variables? { ["updateTodoInput": updateTodoInput] }

  public struct Data: AppSyncAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { AppSyncAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateTodo", UpdateTodo?.self, arguments: ["input": .variable("updateTodoInput")]),
    ] }

    public var updateTodo: UpdateTodo? { __data["updateTodo"] }

    /// UpdateTodo
    ///
    /// Parent Type: `Todo`
    public struct UpdateTodo: AppSyncAPI.SelectionSet {
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
