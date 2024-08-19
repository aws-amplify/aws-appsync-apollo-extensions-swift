//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Apollo
import AppSyncAPI
import Authenticator
import SwiftUI

class ContentViewModel: ObservableObject {

    var activeSubscription: Apollo.Cancellable?

    func list() {
        Network.shared.apolloIAM.fetch(query: MyQuery(), cachePolicy: .fetchIgnoringCacheCompletely) { result in
            switch result {
            case .success(let graphQLResult):
                if let listTodos = graphQLResult.data?.listTodos {
                    print("List todos ", listTodos.items.count)
                    print("List todos ", listTodos.nextToken ?? "")
                }

                if let errors = graphQLResult.errors {
                    print("errors", errors)
                }

            case .failure(let error):
                print("Error fetching todos: \(error)")
            }
        }
    }

    func startSubscription() {
        activeSubscription = Network.shared.apolloIAM.subscribe(subscription: OnCreateSubscription()) { result in
            switch result {
            case .success(let graphQLResult):
                if let todo = graphQLResult.data?.onCreateTodo {
                    print("on create todo ", todo)
                }
                if let errors = graphQLResult.errors {
                    print("errors", errors)
                }
            case .failure(let error):
                print("error", error)
            }
        }
    }

    func unsubscribe() {
        guard let activeSubscription else {
            print("No active subscription")
            return
        }
        print("Cancelling subscription")
        activeSubscription.cancel()
        print("Cancelling subscription completed")
    }

    func mutation() {
        Network.shared.apolloIAM.perform(mutation: CreateTodoMutation(createTodoInput: .init())) { result in
            switch result {
            case .success(let graphQLResult):
                if let todo = graphQLResult.data?.createTodo {
                    print("Created mutation todo ", todo.id)
                }
                if let errors = graphQLResult.errors {
                    print("Errors", errors)
                }
            case .failure(let error):
                print("Error creating todo: \(error)")
            }
        }
    }

}

struct ContentView: View {
    @StateObject var vm = ContentViewModel()

    var body: some View {
        Authenticator { state in
            VStack {
                Button("Sign out") {
                    Task {
                        await state.signOut()
                    }
                }
            }
            VStack {
                Button("List") {
                    vm.list()
                }
                Button("Subscription") {
                    vm.startSubscription()
                }
                Button("Unsub") {
                    vm.unsubscribe()
                }
                Button("mutation") {
                    vm.mutation()
                }
            }
            .padding()
        }
    }

}

#Preview {
    ContentView()
}
