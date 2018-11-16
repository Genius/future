import XCTest

import futureTests

var tests = [XCTestCaseEntry]()
tests += futureTests.allTests()
XCTMain(tests)