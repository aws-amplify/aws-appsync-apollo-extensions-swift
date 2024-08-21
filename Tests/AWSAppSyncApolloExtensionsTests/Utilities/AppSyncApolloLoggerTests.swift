//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//


import XCTest
@testable import AWSAppSyncApolloExtensions

class AppSyncApolloLoggerTests: XCTestCase {

    override func tearDown() async throws {
        // reset to default
        AppSyncApolloLogger.logLevel = AppSyncApolloLogger.LogLevel.error
    }

    func testLogger_withDefaulLogLevel_thenOnlyRecordsErrorLogs() async {
        let expectations = LogExpectations()
        AppSyncApolloLogger.error("error \(expectations.error.fulfill())")

        AppSyncApolloLogger.warn("warn \(expectations.warn.fulfill())")
        expectations.warn.isInverted = true

        AppSyncApolloLogger.info("info \(expectations.info.fulfill())")
        expectations.info.isInverted = true

        AppSyncApolloLogger.debug("debug \(expectations.debug.fulfill())")
        expectations.debug.isInverted = true

        AppSyncApolloLogger.verbose("verbose \(expectations.verbose.fulfill())")
        expectations.verbose.isInverted = true

        await fulfillment(of: expectations.all, timeout: 1)
    }

    func testLogger_withErrorLogLevel_thenOnlyRecordsErrorLogs() async {
        AppSyncApolloLogger.logLevel = .error
        let expectations = LogExpectations()
        AppSyncApolloLogger.error("error \(expectations.error.fulfill())")

        AppSyncApolloLogger.warn("warn \(expectations.warn.fulfill())")
        expectations.warn.isInverted = true

        AppSyncApolloLogger.info("info \(expectations.info.fulfill())")
        expectations.info.isInverted = true

        AppSyncApolloLogger.debug("debug \(expectations.debug.fulfill())")
        expectations.debug.isInverted = true

        AppSyncApolloLogger.verbose("verbose \(expectations.verbose.fulfill())")
        expectations.verbose.isInverted = true

        await fulfillment(of: expectations.all, timeout: 1)
    }

    func testLogger_withWarnLogLevel_thenOnlyRecordsErrorWarnLogs() async {
        AppSyncApolloLogger.logLevel = .warn
        let expectations = LogExpectations()
        AppSyncApolloLogger.error("error \(expectations.error.fulfill())")

        AppSyncApolloLogger.warn("warn \(expectations.warn.fulfill())")

        AppSyncApolloLogger.info("info \(expectations.info.fulfill())")
        expectations.info.isInverted = true

        AppSyncApolloLogger.debug("debug \(expectations.debug.fulfill())")
        expectations.debug.isInverted = true

        AppSyncApolloLogger.verbose("verbose \(expectations.verbose.fulfill())")
        expectations.verbose.isInverted = true

        await fulfillment(of: expectations.all, timeout: 1)
    }

    func testLogger_withInfoLogLevel_thenOnlyRecordsErrorWarnInfoLogs() async {
        AppSyncApolloLogger.logLevel = .info
        let expectations = LogExpectations()
        AppSyncApolloLogger.error("error \(expectations.error.fulfill())")

        AppSyncApolloLogger.warn("warn \(expectations.warn.fulfill())")

        AppSyncApolloLogger.info("info \(expectations.info.fulfill())")

        AppSyncApolloLogger.debug("debug \(expectations.debug.fulfill())")
        expectations.debug.isInverted = true

        AppSyncApolloLogger.verbose("verbose \(expectations.verbose.fulfill())")
        expectations.verbose.isInverted = true

        await fulfillment(of: expectations.all, timeout: 1)
    }

    func testLogger_withDebugLogLevel_thenOnlyRecordsErrorWarnInfoDebugLogs() async {
        AppSyncApolloLogger.logLevel = .debug
        let expectations = LogExpectations()
        AppSyncApolloLogger.error("error \(expectations.error.fulfill())")

        AppSyncApolloLogger.warn("warn \(expectations.warn.fulfill())")

        AppSyncApolloLogger.info("info \(expectations.info.fulfill())")

        AppSyncApolloLogger.debug("debug \(expectations.debug.fulfill())")

        AppSyncApolloLogger.verbose("verbose \(expectations.verbose.fulfill())")
        expectations.verbose.isInverted = true

        await fulfillment(of: expectations.all, timeout: 1)
    }

    func testLogger_withVerboseLogLevel_thenOnlyRecordsErrorWarnInfoDebugVerboseLogs() async {
        AppSyncApolloLogger.logLevel = .verbose
        let expectations = LogExpectations()
        AppSyncApolloLogger.error("error \(expectations.error.fulfill())")

        AppSyncApolloLogger.warn("warn \(expectations.warn.fulfill())")

        AppSyncApolloLogger.info("info \(expectations.info.fulfill())")

        AppSyncApolloLogger.debug("debug \(expectations.debug.fulfill())")

        AppSyncApolloLogger.verbose("verbose \(expectations.verbose.fulfill())")

        await fulfillment(of: expectations.all, timeout: 1)
    }

}


fileprivate struct LogExpectations {
    let error = XCTestExpectation(description: "error message was evaluated")
    let warn = XCTestExpectation(description: "warn message was evaluated")
    let info = XCTestExpectation(description: "info message was evaluated")
    let debug = XCTestExpectation(description: "debug message was evaluated")
    let verbose = XCTestExpectation(description: "verbose message was evaluated")

    var all: [XCTestExpectation] {
        [error, warn, info, debug, verbose]
    }
}
