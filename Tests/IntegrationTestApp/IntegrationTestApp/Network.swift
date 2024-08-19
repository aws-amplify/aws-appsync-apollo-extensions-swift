//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Apollo
import ApolloAPI
import ApolloWebSocket
import AWSAppSyncApolloInterceptors
import AWSCognitoAuthPlugin
import AWSPluginsCore
import Foundation

class Network {
    static let shared = Network()
    let configuration = try! AWSAppSyncConfiguration(with: .amplifyOutputs)

    private(set) lazy var apolloAPIKey: ApolloClient = {
        let store = ApolloStore(cache: InMemoryNormalizedCache())

        let authorizer = APIKeyAuthorizer(apiKey: configuration.apiKey ?? "")
        let interceptor = AppSyncInterceptor(authorizer)

        let interceptorProvider = DefaultPrependInterceptorProvider(interceptor: interceptor,
                                                                    store: store)
        let transport = RequestChainNetworkTransport(interceptorProvider: interceptorProvider,
                                                     endpointURL: configuration.endpoint)
        let websocket = AppSyncWebSocketClient(endpointURL: configuration.endpoint,
                                               authorizer: authorizer)
        let webSocketTransport = WebSocketTransport(websocket: websocket)
        let splitTransport = SplitNetworkTransport(
            uploadingNetworkTransport: transport,
            webSocketNetworkTransport: webSocketTransport
        )
        return ApolloClient(networkTransport: splitTransport, store: store)
    }()

    private(set) lazy var apolloCUP: ApolloClient = {
        let store = ApolloStore(cache: InMemoryNormalizedCache())

        let authorizer = AuthTokenAuthorizer(fetchLatestAuthToken: Network.getUserPoolAccessToken)
        let interceptorProvider = DefaultPrependInterceptorProvider(interceptor:  AppSyncInterceptor(authorizer),
                                                                    store: store)
        let transport = RequestChainNetworkTransport(interceptorProvider: interceptorProvider,
                                                     endpointURL: configuration.endpoint)
        let websocket = AppSyncWebSocketClient(endpointURL: configuration.endpoint,
                                               authorizer: authorizer)
        let webSocketTransport = WebSocketTransport(websocket: websocket)
        let splitTransport = SplitNetworkTransport(
            uploadingNetworkTransport: transport,
            webSocketNetworkTransport: webSocketTransport
        )
        return ApolloClient(networkTransport: splitTransport, store: store)
    }()

    private(set) lazy var apolloIAM: ApolloClient = {
        let store = ApolloStore(cache: InMemoryNormalizedCache())

        let authorizer = IAMAuthorizer(
            signRequest: AWSCognitoAuthPlugin.createAppSyncSigner(
                region: configuration.region))

        let interceptorProvider = DefaultPrependInterceptorProvider(interceptor: AppSyncInterceptor(authorizer),
                                                                    store: store)
        let transport = RequestChainNetworkTransport(interceptorProvider: interceptorProvider,
                                                     endpointURL: configuration.endpoint)
        let websocket = AppSyncWebSocketClient(endpointURL: configuration.endpoint,
                                               authorizer: authorizer)
        let webSocketTransport = WebSocketTransport(websocket: websocket)
        let splitTransport = SplitNetworkTransport(
            uploadingNetworkTransport: transport,
            webSocketNetworkTransport: webSocketTransport
        )

        return ApolloClient(networkTransport: splitTransport, store: store)
    }()

    static func getUserPoolAccessToken() async throws -> String {
        let authSession = try await Amplify.Auth.fetchAuthSession()
        if let result = (authSession as? AuthCognitoTokensProvider)?.getCognitoTokens() {
            switch result {
            case .success(let tokens):
                return tokens.accessToken
            case .failure(let error):
                throw error
            }
        }
        throw AuthError.unknown("Did not receive a valid response from fetchAuthSession for get token.")
    }
}

