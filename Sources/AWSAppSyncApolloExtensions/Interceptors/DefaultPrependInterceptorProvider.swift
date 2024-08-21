//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Apollo
import ApolloAPI
import Foundation

public class DefaultPrependInterceptorProvider: DefaultInterceptorProvider {

    let interceptor: ApolloInterceptor

    public init(interceptor: ApolloInterceptor,
                client: URLSessionClient = URLSessionClient(),
                shouldInvalidateClientOnDeinit: Bool = true,
                store: ApolloStore)
    {
        self.interceptor = interceptor
        super.init(client: client, shouldInvalidateClientOnDeinit: shouldInvalidateClientOnDeinit, store: store)
    }

    override public func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] where Operation: GraphQLOperation {
        var interceptors = super.interceptors(for: operation)

        addInterceptorToBeginning(&interceptors)

        return interceptors
    }

    func addInterceptorToBeginning(_ interceptors: inout [any ApolloInterceptor]) {
        interceptors.insert(interceptor, at: 0)
    }
}

