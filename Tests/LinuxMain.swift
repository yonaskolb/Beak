import XCTest

import BeakTests

var tests = [XCTestCaseEntry]()
tests += BeakTests.__allTests()

XCTMain(tests)
