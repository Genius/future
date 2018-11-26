import XCTest

import FutureTests

var tests = [XCTestCaseEntry]()
tests += FutureTests.__allTests()

XCTMain(tests)
