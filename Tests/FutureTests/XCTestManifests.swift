import XCTest

extension FutureAllTests {
    static let __allTests = [
        ("testLikeTypeFuturesAllNoSuccesses", testLikeTypeFuturesAllNoSuccesses),
        ("testLikeTypeFuturesAllSomeSuccesses", testLikeTypeFuturesAllSomeSuccesses),
        ("testLikeTypeFuturesAllSuccesses", testLikeTypeFuturesAllSuccesses),
    ]
}

extension FutureAnyTests {
    static let __allTests = [
        ("testLikeTypeFuturesAnyAllSuccesses", testLikeTypeFuturesAnyAllSuccesses),
        ("testLikeTypeFuturesAnyNoSuccesses", testLikeTypeFuturesAnyNoSuccesses),
        ("testLikeTypeFuturesAnySomeSuccesses", testLikeTypeFuturesAnySomeSuccesses),
    ]
}

extension FutureFirstTests {
    static let __allTests = [
        ("testLikeTypeFuturesFirstError", testLikeTypeFuturesFirstError),
        ("testLikeTypeFuturesFirstSuccess", testLikeTypeFuturesFirstSuccess),
    ]
}

extension FutureTests {
    static let __allTests = [
        ("testAlways", testAlways),
        ("testAsync", testAsync),
        ("testChaining", testChaining),
        ("testFailingFuture", testFailingFuture),
        ("testSuccessFuture", testSuccessFuture),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FutureAllTests.__allTests),
        testCase(FutureAnyTests.__allTests),
        testCase(FutureFirstTests.__allTests),
        testCase(FutureTests.__allTests),
    ]
}
#endif
