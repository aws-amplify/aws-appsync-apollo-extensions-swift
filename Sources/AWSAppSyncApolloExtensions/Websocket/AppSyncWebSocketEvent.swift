//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public enum AppSyncWebSocketEvent {
    case connected
    case disconnected(URLSessionWebSocketTask.CloseCode, String?)
    case data(Data)
    case string(String)
    case error(Error)
}
