// ====--------------------------------------------------------====
// Futures
// https://github.com/genius/future
// ====--------------------------------------------------------====

import Foundation

// ====--------------------------------------------------------====
/*
Future [Result|Error]Collections are thin wrappers around arrays (themselves
available as .rawValue) in order to solve the [E] !== Swift.Error issue.
*/

extension Future {
/**
A thin wrapper around an array of values returned by a collection
of Futures.
     
```
     Futures.all([doAsyncThing(), doOtherAsyncThing()]).then { results in
        let arrayValue = results.rawValue
        // or...
        let result = results[0]
     }
```
*/
    public struct ResultCollection {
        fileprivate(set) public var rawValue = [T]()
        
        public subscript(_ index: Int) -> T {
            return self.rawValue[index]
        }
    }
    
/**
A thin wrapper around an array of errors returned by a collection
of Futures.
     
```
     Futures.all([doAsyncThing(), doOtherAsyncThing()]).catch { errors in
        let arrayValue = errors
        // or...
        let result = results[0]
     }
```
*/

    public struct ErrorCollection: Swift.Error {
        fileprivate(set) public var rawValue = [E]()
        
        public subscript(_ index: Int) -> E {
            return self.rawValue[index]
        }
    }
}

// ====--------------------------------------------------------====

public enum Futures {
/**
Returns a Future that will be resolved after all passed futures complete that will be successful if all of the original futures are
successful. This method makes no assumption about order or thread delivery.
*/
    public static func all<T: Any, E: Error>(_ futures: [Future<T, E>]) -> Future<Future<T, E>.ResultCollection, Future<T, E>.ErrorCollection> {
        return Future { resolver in
            var results = Future<T, E>.ResultCollection()
            var errors = Future<T, E>.ErrorCollection()
            let totalCount = futures.count
            
            futures.forEach { future in
                future.always { result, error in
                    if let result = result {
                        results.rawValue.append(result)
                    } else {
                        errors.rawValue.append(error!)
                    }
                    
                    let resolvedCount = results.rawValue.count + errors.rawValue.count
                    if resolvedCount == totalCount {
                        if errors.rawValue.isEmpty {
                            resolver.resolve(value: results)
                        } else {
                            resolver.reject(error: errors)
                        }
                    }
                }
            }
        }
    }
    
/**
Returns a Future that will be resolved after all passed futures complete that will be successful if any of the original futures are
successful. This method makes no assumption about order or thread delivery.
*/

    public static func any<T: Any, E: Error>(_ futures: [Future<T , E>]) -> Future<Future<T, E>.ResultCollection, Future<T, E>.ErrorCollection> {
        return Future { resolver in
            var results = Future<T, E>.ResultCollection()
            var errors = Future<T, E>.ErrorCollection()
            let totalCount = futures.count
            
            futures.forEach { future in
                future.always { result, error in
                    if let result = result {
                        results.rawValue.append(result)
                    } else {
                        errors.rawValue.append(error!)
                    }
                    
                    let resolvedCount = results.rawValue.count + errors.rawValue.count
                    if resolvedCount == totalCount {
                        if results.rawValue.isEmpty {
                            resolver.reject(error: errors)
                        } else {
                            resolver.resolve(value: results)
                        }
                    }
                }
            }
        }
    }
    
/**
Returns a Future that will be resolved or rejected with the value or error of the first future to complete. If multiple
Futures are already resolved at the time `first` is called, the first resolved future in the passed array will be used.
*/

    public static func first<T: Any, E: Error>(_ futures: [Future<T, E>]) -> Future<T, E> {
        return Future { resolver in
            // Safe due to the feature that calling resolve on a resolved Future's resolver is, basically, a no-op
            futures.forEach { future in
                future.then { value in
                    resolver.resolve(value: value)
                    
                }.catch { error in
                    resolver.reject(error: error)
                    
                }
            }
        }
    }
}

