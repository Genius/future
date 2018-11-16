import XCTest
@testable import Future

private enum FutureError: Int, Error {
    case failure
    case otherFailure
}

final class FutureTests: XCTestCase {
    static var allTests = [
        ("testSuccessFuture", testSuccessFuture),
        ("testFailingFuture", testFailingFuture),
        ("testChaining", testChaining),
        ("testAsync", testAsync),
        ("testAlways", testAlways)
    ]
    
    func testSuccessFuture() {
        let future: Future<Bool, FutureError> = Future { resolver in
            resolver.resolve(value: true)
        }
        
        future.then { result in
            XCTAssertEqual(result, true)
        }
        
        future.catch { _ in
            XCTFail()
        }
    }
    
    func testFailingFuture() {
        let future: Future<Bool, FutureError> = Future { resolver in
            resolver.reject(error: .failure)
        }
        
        future.then { _ in
            XCTFail()
        }
        
        future.catch { error in
            XCTAssertEqual(error, .failure)
        }
    }
    
    func testChaining() {
        let future: Future<Bool, FutureError> = Future { resolver in
            resolver.resolve(value: true)
        }
        
        future.then { result in
            XCTAssertEqual(result, true)
        }.then { result in
            XCTAssertEqual(result, true)
        }.catch { _ in
            XCTFail()
        }
    }
    
    func testAsync() {
        let future: Future<Bool, FutureError> = Future { resolver in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                resolver.resolve(value: true)
            }
        }
        
        let expectation = self.expectation(description: "Async futures should work")
        future.then { success in
            XCTAssertEqual(success, true)
            expectation.fulfill()
            
        }.catch { _ in
            XCTFail()
        }
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func testAlways() {
        let futureOne: Future<Bool, FutureError> = Future { resolver in
            resolver.reject(error: .otherFailure)
        }
        
        futureOne.always { value, error in
            XCTAssertNil(value)
            XCTAssertNotNil(error)
        }
        
        let futureTwo: Future<Bool, FutureError> = Future { resolver in
            resolver.resolve(value: true)
        }
        
        futureTwo.always { value, error in
            XCTAssertNotNil(value)
            XCTAssertNil(error)
        }
    }
}
