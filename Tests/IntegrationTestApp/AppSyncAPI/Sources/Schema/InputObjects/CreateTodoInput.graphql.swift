// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct CreateTodoInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    content: GraphQLNullable<String> = nil,
    id: GraphQLNullable<ID> = nil
  ) {
    __data = InputDict([
      "content": content,
      "id": id
    ])
  }

  public var content: GraphQLNullable<String> {
    get { __data["content"] }
    set { __data["content"] = newValue }
  }

  public var id: GraphQLNullable<ID> {
    get { __data["id"] }
    set { __data["id"] = newValue }
  }
}
