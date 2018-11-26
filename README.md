# Future

A Future is a simplified take on Promises, written in Swift. It aims to provide the following for it's users:

1. A clean separation of success & error handlers, with no optional values in completion blocks.
2. Type-safe error handling
3. An easy to use call site that better matches how we _describe_ code.

## Simple Usage

When calling a method which returns a Future:

```
doAsyncThing().then { result in 
	// do something with result
}
```

Result, here, will be non-optional and the `then` block will only be called if the future has completed successfully.

Error handling is done similarly:

```
doAsyncThingThatErrors().catch { error in 
	// do something with error
}
```

Errors here are also non-optional, and of the type defined by the Future itself (as opposed to non-typed `throws` calls)

## Returning A Future

Futures rely heavily on generics to provide type safety. 

```
func doAsyncThing() -> Future<Int, MyError> {
}
```

The first value of the Future<> definition denotes the type expected with a successful Future, the second denotes the type expected with a failing Future. The error type must conform to Swift's own `Error` type.

The Future's initializer aims to retain type safety, but eliminate as much of the tedious type annotations as possible.

```
func doAsyncThing() -> Future<Int, MyError> {
	return Future { resolver in 
		// ...
	}
}
```

The `resolver` value here passed into the block is a Result.Resolver, which has two methods:

`resolver.resolve(value:)`

and

`resolver.reject(error:)`

Which will either resolve or reject the associated Future appropriately. 

## Grouping Futures

Some methods to compose Futures exist on the `Futures` namespace. They are:

`Futures.all()`

Which returns a Future which will be resolved with a Collection of Results if, and only if, all of the passed Futures complete successfully.

`Futures.any()`

Which returns a Future which will be resolved with a Collection of Results if one or more of the passed Futures complete successfully.

`Futures.first()`

Which returns a Future which will resolve or reject with the value of the first passed Future which completes.


## Installation

### SwiftPM

Right now the preferred way to try out Futures is via the Swift Package Manager.

```
.package(url: "https://github.com/genius/future", from: "0.0.1")
```

### Manually

You can also copy the `Future.swift` file from the `Sources` directory of your own project if installation via the Swift Package Manager is not available to you.

## Contributing

Bug reports, constructive feedback and pull requests are always welcome. If you're using Futures in your own apps, we'd love to hear about it.
