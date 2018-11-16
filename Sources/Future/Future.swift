import Foundation

/**
 A Future is a simplified Promise whose main goals are:
 
 1. Guaranteed type-safe values & errors in success and error blocks
 2. A simplified async code flow where then / catch can be called and the
 code inside the block will be executed appropriately regardless of Future
 state when called.
 3. Cleaner, more literate async method call sites.
 
 A Future has an associated Future.Resolver object whose job is to
 set and update the internal success / failure state of the Future itself.
 Whereas the Future should be considered safe and idiomatic to store and pass
 around, the Resolver shouldn't be.
*/

public final class Future<T: Any, E: Error> {
    public typealias Value = T
    public typealias Error = E

// ====--------------------------------------------------------====

/**
The Resolver is in charge of resolving or rejecting the associated
future, and should only be used inside the initializer block. Calling
resolve() or reject() on the resolver will trigger the associated
blocks on the Future
*/

    public final class Resolver {
        fileprivate weak var _future: Future<T, E>?
        fileprivate init(_ future: Future<T, E>) {
            self._future = future
        }
        
/**
Sets the final state of the associated Future to the value, and
immediately calls all then() observers with the value.
*/

        func resolve(value: Value) {
            self._future?.resolve(value: value)
            self._future = nil
        }

/**
Sets the final state of the associated Future to the error, and
immediately calls all catch() observers with the error.
*/

        func reject(error: Error) {
            self._future?.reject(error: error)
            self._future = nil
        }
    }
    
    // Store the success / error values for future bindings
    private var _value: Value?
    private var _error: Error?
    
    // Store the observers for success / errors
    private var _observers = [((Value) -> Void)]()
    private var _errorObservers = [((Error) -> Void)]()
    
    public var isResolved: Bool {
        return self._value != nil || self._error != nil
    }
    
// ====--------------------------------------------------------====
// MARK: - Init, etc...
    
    public init(_ block: (Future<T, E>.Resolver) -> Void) {
        let resolver = Resolver(self)
        block(resolver)
    }

// ====--------------------------------------------------------====
// MARK: - State Updating
    
    private func resolve(value: Value) {
        guard !self.isResolved else {
            // TODO: Is returning early here the right decision?
            return
        }
        
        self._value = value
        self._observers.forEach { $0(value) }
    }
    
    private func reject(error: Error) {
        guard !self.isResolved else {
            // TODO: Is returning early here the right decision?
            return
        }

        self._error = error
        self._errorObservers.forEach { $0(error) }
    }
    
// ====--------------------------------------------------------====
// MARK: - Handlers
    
/**
Adds a success handler which will be invoked immediately if the Future has
already been resolved successfully with a Value, or some time in the future
when this has occurred. Returns itself.
*/
    
    @discardableResult
    public func then(_ block: @escaping ((Value) -> Void)) -> Future<Value, Error> {
        if let value = self._value {
            block(value)
            
        } else {
            self._observers.append(block)
        }
        
        return self
    }
    
/**
Adds an error handler which will be invoked immediately if the Future has
already been rejected with an Error, or some time in the future
when this has occurred. Returns itself.
*/

    @discardableResult
    public func `catch`(_ block: @escaping ((Error) -> Void)) -> Future<Value, Error> {
        if let error = self._error {
            block(error)
            
        } else {
            self._errorObservers.append(block)
        }
        
        return self
    }
    
/**
Adds a block handler containing optional Value and Error types which will always be
called whenever the Future completes.
*/
    
    @discardableResult
    public func always(_ block: @escaping ((Value?, Error?) -> Void)) -> Future<Value, Error> {
        if let value = self._value {
            block(value, nil)
            
        } else if let error = self._error {
            block(nil, error)
            
        } else {
            self._observers.append({ value in
                block(value, nil)
            })
            
            self._errorObservers.append({ error in
                block(nil, error)
            })
        }

        return self
    }
}

extension Future.Resolver where T == Void {
    func resolve() {
        self.resolve(value: ())
    }
}
