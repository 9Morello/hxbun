package helpers;

import result.Result;
import js.lib.Promise;
import haxe.Exception;

/**
 * A ResultPromise is a Promise that returns a `Result<T, E>`, and never rejects.
**/
@:using(helpers.ResultPromise.ResultPromiseTools) typedef ResultPromise<T, E> = Promise<Result<T, E>>;

/**
 * Static helpers for the `ResultPromise` type.
 * Thanks to mnemesong for the original implementation.  
**/
class ResultPromiseTools {
	/**
		Checks that Result is Ok
	**/
	public static inline function isOk<T, E>(t:ResultPromise<T, E>):Promise<Bool> {
		return t.then(v -> v.match(Ok(_)));
	}

	/**
		Try to get value of Result or throws Exception
	**/
	public static inline function getVal<T, E>(t:ResultPromise<T, E>):Promise<T> {
		return t.then(v -> switch (v) {
			case Ok(s):
				return s;
			case Error(_):
				throw new Exception("Trying to get Error as value");
		});
	}

	/**
		Try to get value of Result or get default value
	**/
	public static inline function getWithDefault<T, E>(t:ResultPromise<T, E>, a:T):Promise<T> {
		return t.then(v -> switch (v) {
			case Ok(s):
				return s;
			case Error(_):
				return a;
		});
	}

	/**
		Applies a function to a `ResultPromise`, and returns a new `ResultPromise`.
		In case the original Promise returned an error, that error is returned instead.
	**/
	public static inline function andThen<T, B, E>(t:ResultPromise<T, E>, fn:(a:T) -> ResultPromise<B, E>):ResultPromise<B, E> {
		return t.then(v -> switch (v) {
			case Ok(s):
				return fn(s);
			case Error(e):
				return Promise.resolve(Error(e));
		});
	}

	/**
		Apply function to Result value or continue Error
	**/
	public static inline function map<T, B, E>(t:ResultPromise<T, E>, fn:(a:T) -> B):ResultPromise<B, E> {
		return t.then(v -> switch (v) {
			case Ok(s):
				return Ok(fn(s));
			case Error(e):
				return Error(e);
		});
	}

	/**
		Apply filtering function to value of Result or continue Error
	**/
	public static inline function filter<T, E, FE>(t:ResultPromise<T, E>, fn:(a:T) -> Bool, errVal:FE):ResultPromise<T, FilterError<FE, E>> {
		return t.then(v -> switch (v) {
			case Ok(s):
				return fn(s) ? Ok(s) : Error(Filtered(errVal));
			case Error(e):
				return Error(PreviousError(e));
		});
	}

	/**
	 * Wraps a `Promise<T>` into a `ResultPromise<T, Any>` that returns `Result<T, Any>` when fullfilled,
	 * and never throws.
	 * @param promise 
	 * @return ResultPromise<T, Any>
	**/
	inline function wrapPromise<T>(promise:Promise<T>):ResultPromise<T, Any> {
		return promise.then((value:T) -> Result.Ok(value), (err) -> Result.Error(err));
	}
}

/**
 * Errors thrown by the `filter` function.
 * The error indicates whether your result got filtered, or if it failed at a previous step,
 *  before the filter was applied. 
**/
enum FilterError<FE, E> {
	Filtered(err:FE);
	PreviousError(e:E);
}
