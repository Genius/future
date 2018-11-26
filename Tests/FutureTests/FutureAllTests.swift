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

final class FutureAllTests: XCTestCase {
    static var allTests = [
        ("testLikeTypeFuturesAllSuccesses", testLikeTypeFuturesAllSuccesses),
        ("testLikeTypeFuturesAllSomeSuccesses", testLikeTypeFuturesAllSomeSuccesses),
        ("testLikeTypeFuturesAllNoSuccesses", testLikeTypeFuturesAllNoSuccesses)
    ]
    
    func testLikeTypeFuturesAllSuccesses() {
        let futureOne = Future<Int, FutureError> { resolver in
            resolver.resolve(value: 1)
        }
        
        let futureTwo = Future<Int, FutureError> { resolver in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                resolver.resolve(value: 2)
            }
        }
        
        let expectation = self.expectation(description: "Futures.all will resolve")
        let future = Futures.all([futureOne, futureTwo])
        
        future.then { results in
            XCTAssertEqual(results.rawValue.count, 2)
            expectation.fulfill()
            
        }.catch { _ in
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testLikeTypeFuturesAllSomeSuccesses() {
        let futureOne = Future<Int, FutureError> { resolver in
            resolver.resolve(value: 1)
        }
        
        let futureTwo = Future<Int, FutureError> { resolver in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                resolver.reject(error: .failure)
            }
        }
        
        let expectation = self.expectation(description: "Futures.all will reject")
        let future = Futures.all([futureOne, futureTwo])
        
        future.then { _ in
            XCTFail()
            
        }.catch { errors in
            XCTAssertEqual(errors.rawValue.count, 1)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testLikeTypeFuturesAllNoSuccesses() {
        let futureOne = Future<Int, FutureError> { resolver in
            resolver.reject(error: .failure)
        }
        
        let futureTwo = Future<Int, FutureError> { resolver in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                resolver.reject(error: .failure)
            }
        }
        
        let expectation = self.expectation(description: "Futures.all will reject")
        let future = Futures.all([futureOne, futureTwo])
        
        future.then { results in
            XCTFail()
            
        }.catch { errors in
            XCTAssertEqual(errors.rawValue.count, 2)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
}
