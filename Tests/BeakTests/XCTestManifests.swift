import XCTest

extension BeakTests {
    static let __allTests = [
        ("testBeak", testBeak),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BeakTests.__allTests),
    ]
}
#endif
