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

final class FutureAnyTests: XCTestCase {
    static var allTests = [
        ("testLikeTypeFuturesAnyAllSuccesses", testLikeTypeFuturesAnyAllSuccesses),
        ("testLikeTypeFuturesAnySomeSuccesses", testLikeTypeFuturesAnySomeSuccesses),
        ("testLikeTypeFuturesAnyNoSuccesses", testLikeTypeFuturesAnyNoSuccesses)
    ]
    
    func testLikeTypeFuturesAnyAllSuccesses() {
        let futureOne = Future<Int, FutureError> { resolver in
            resolver.resolve(value: 1)
        }
        
        let futureTwo = Future<Int, FutureError> { resolver in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                resolver.resolve(value: 2)
            }
        }
        
        let expectation = self.expectation(description: "Futures.any will resolve")
        let future = Futures.any([futureOne, futureTwo])
        
        future.then { results in
            XCTAssertEqual(results.rawValue.count, 2)
            expectation.fulfill()
            
        }.catch { _ in
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testLikeTypeFuturesAnySomeSuccesses() {
        let futureOne = Future<Int, FutureError> { resolver in
            resolver.resolve(value: 1)
        }
        
        let futureTwo = Future<Int, FutureError> { resolver in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                resolver.reject(error: .failure)
            }
        }
        
        let expectation = self.expectation(description: "Futures.first will resolve")
        let future = Futures.any([futureOne, futureTwo])
        
        future.then { results in
            XCTAssertEqual(results.rawValue.count, 1)
            expectation.fulfill()
            
        }.catch { _ in
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }

    func testLikeTypeFuturesAnyNoSuccesses() {
        let futureOne = Future<Int, FutureError> { resolver in
            resolver.reject(error: .failure)
        }
        
        let futureTwo = Future<Int, FutureError> { resolver in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                resolver.reject(error: .failure)
            }
        }
        
        let expectation = self.expectation(description: "Futures.first will reject")
        let future = Futures.any([futureOne, futureTwo])
        
        future.then { results in
            XCTFail()
            
        }.catch { errors in
            XCTAssertEqual(errors.rawValue.count, 2)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
}
