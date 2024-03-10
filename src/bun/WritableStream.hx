package bun;

import haxe.extern.EitherType;
import js.lib.Promise;

/**
 * This Streams API interface provides a standard abstraction for writing
 * streaming data to a destination, known as a sink. This object comes with
 * built-in back pressure and queuing.
 */
extern class WritableStream<T> {
	public var locked(default, never):Bool;
	public function abort(?reason:Any):js.lib.Promise<Void>;
	public function close():js.lib.Promise<Void>;
	public function getWriter(?encoding:String, ?mode:String):Dynamic<T>;

	public function new(?underlyingSink:UnderlyingSink<T>, ?strategy:QueuingStrategy<T>);
}

typedef UnderlyingSink<T = Any> = {
	abort:(?reason:Any) -> EitherType<Void, Promise<Void>>,
	close:() -> EitherType<Void, Promise<Void>>,
	start:(controller:WritableStreamDefaultController) -> Any,
	write:(chunk:T, controller:WritableStreamDefaultController) -> EitherType<Void, Promise<Void>>
};

typedef WritableStreamDefaultController = {
	?error:(?error:Any) -> Void
};
