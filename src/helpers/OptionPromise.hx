package helpers;

import haxe.ds.Option;
import js.lib.Promise;

/**
 * An OptionPromise is a Promise that returns an `Option<T>`, and never rejects.
**/
typedef OptionPromise<T> = Promise<Option<T>>;

/**
 * Wraps a `Promise<T>` into an `OptionPromise<T>` that returns `Option<T>` when fullfilled,
 * and never throws.
 * @param promise 
 * @return OptionPromise<T>
**/
inline function wrapPromise<T>(promise:Promise<T>):OptionPromise<T> {
	return promise.then((value:T) -> Some(value), (_) -> None);
}
