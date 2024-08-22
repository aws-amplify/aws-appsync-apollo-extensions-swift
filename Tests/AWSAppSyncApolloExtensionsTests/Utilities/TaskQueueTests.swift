//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//


import XCTest
@testable import AWSAppSyncApolloExtensions

final class TaskQueueTests: XCTestCase {

    /// Test basic TaskQueue.sync behavior
    ///
    /// - Given: A task queue
    /// - When: I add tasks to the queue using the `sync` method
    /// - Then: The tasks execute in the order added
    func testSync() async throws {
        for _ in 1 ... 1_000 {
            try await doSyncTest()
        }
    }

    func doSyncTest() async throws {
        let expectation1 = expectation(description: "expectation1")
        let expectation2 = expectation(description: "expectation2")
        let expectation3 = expectation(description: "expectation3")

        let taskQueue = TaskQueue<Void>()
        try await taskQueue.sync {
            try await Task.sleep(nanoseconds: 1)
            expectation1.fulfill()
        }

        try await taskQueue.sync {
            try await Task.sleep(nanoseconds: 1)
            expectation2.fulfill()
        }

        try await taskQueue.sync {
            try await Task.sleep(nanoseconds: 1)
            expectation3.fulfill()
        }

        await fulfillment(of: [expectation1, expectation2, expectation3], enforceOrder: true)
    }

    func testAsync() async throws {
        let taskCount = 1_000
        let expectations: [XCTestExpectation] = (0..<taskCount).map {
            expectation(description: "Expected execution of a task number \($0)")
        }

        let taskQueue = TaskQueue<Void>()

        for i in 0..<taskCount {
            taskQueue.async {
                expectations[i].fulfill()
            }
        }

        await fulfillment(of: expectations, enforceOrder: true)
    }
}
