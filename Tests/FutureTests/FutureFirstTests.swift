// ====--------------------------------------------------------====
// Futures
// https://github.com/genius/future
// ====--------------------------------------------------------====

import XCTest
@testable import Future

private enum FutureError: Int, Error {
    case failure
    case otherFailure
}

// ====--------------------------------------------------------====

final class FutureFirstTests: XCTestCase {
    static var allTests = [
        ("testLikeTypeFuturesFirstSuccess", testLikeTypeFuturesFirstSuccess),
        ("testLikeTypeFuturesFirstError", testLikeTypeFuturesFirstError)
    ]
    
    func testLikeTypeFuturesFirstSuccess() {
        let futureOne = Future<Int, FutureError> { resolver in
            resolver.resolve(value: 1)
        }
        
        let futureTwo = Future<Int, FutureError> { resolver in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                resolver.resolve(value: 2)
            }
        }
        
        let expectation = self.expectation(description: "Futures.first will resolve")
        Futures.first([futureOne, futureTwo]).then { value in
            XCTAssertEqual(value, 1)
            expectation.fulfill()
        }.catch { _ in
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testLikeTypeFuturesFirstError() {
        let futureOne = Future<Int, FutureError> { resolver in
            resolver.reject(error: .failure)
        }
        
        let futureTwo = Future<Int, FutureError> { resolver in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                resolver.reject(error: .otherFailure)
            }
        }
        
        let expectation = self.expectation(description: "Futures.first will reject")
        Futures.first([futureOne, futureTwo]).then { value in
            XCTFail()
        }.catch { error in
            XCTAssertEqual(error, .failure)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
}
