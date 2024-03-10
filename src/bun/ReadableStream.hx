package bun;

import haxe.extern.EitherType;
import js.lib.Promise;

/**
	This Streams API interface represents a readable stream of byte data. 
	The Fetch API offers a concrete instance of a ReadableStream through the body property of a Response object.
**/
@:native("ReadableStream") extern class ReadableStream<T = Any> {
	function new<T>(?underlyingSource:UnderlyingSource<T>, ?strategy:QueuingStrategy<T>);

	final locked:Bool;
	function cancel(?reason:Dynamic):Promise<Void>;
	function getReader():Reader<T>;

	// function pipeThrough<T>(transform:ReadableWritablePair<T, T>, ?options:StreamPipeOptions):ReadableStream<T>;

	/**
	 * Pipes this readable stream to a given writable stream destination. 
	 * The way in which the piping process behaves under various error conditions can be customized with a number of passed options. 
	 * It returns a promise that fulfills when the piping process completes successfully, or rejects if any errors were encountered.
	 * @param destination The `WritableStream` instance to pipe this stream to.
	 * @param options 
	 * @return Promise<Void>
	 */
	function pipeTo(destination:WritableStream<T>, ?options:StreamPipeOptions):Promise<Void>;

	function values(?options:{preventCancel:Bool}):Iterable<T>;
	static var prototype:ReadableStream<Dynamic>;
}

typedef UnderlyingSource<T> = {
	?cancel:(?reason:Dynamic) -> EitherType<Void, Promise<Void>>,
	?pull:(controller:ReadableStreamController<T>) -> EitherType<Void, Promise<Void>>,
	?start:(controller:ReadableStreamController<T>) -> Dynamic,
	?type:Any
};

@:native("ReadableStreamDefaultController") extern class ReadableStreamController<T> {
	public function new();
	final desiredSize:Null<Float>;
	function close():Void;
	function enqueue(?chunk:T):Void;
	function error(?e:Dynamic):Void;
}

@:native("ReadableStreamDefaultReader") extern class Reader<T> {
	function new<T>(stream:ReadableStream<T>);
	function read():Promise<{done:Bool, ?value:T, ?size:Int}>;

	/**
		Only available in Bun. If there are multiple chunks in the queue, this will return all of them at the same time.
	**/
	function readMany():js.lib.Promise<{done:Bool, ?value:Array<T>, ?size:Int}>;

	function releaseLock():Void;
	final closed:js.lib.Promise<Null<Any>>;
	function cancel(?reason:Dynamic):Promise<Void>;
}

/**
	Errors and closures of the source and destination streams propagate as follows:

	An error in this source readable stream will abort destination, unless preventAbort is truthy. The returned promise will be rejected with the source's error, or with any error that occurs during aborting the destination.

	An error in destination will cancel this source readable stream, unless preventCancel is truthy. The returned promise will be rejected with the destination's error, or with any error that occurs during canceling the source.

	When this source readable stream closes, destination will be closed, unless preventClose is truthy. The returned promise will be fulfilled once this process completes, unless an error is encountered while closing the destination, in which case it will be rejected with that error.

	If destination starts out closed or closing, this source readable stream will be canceled, unless preventCancel is true. The returned promise will be rejected with an error indicating piping to a closed stream failed, or with any error that occurs during canceling the source.

	The signal option can be set to an AbortSignal to allow aborting an ongoing pipe operation via the corresponding AbortController. In this case, this source readable stream will be canceled, and destination aborted, unless the respective options preventCancel or preventAbort are set.
**/
typedef StreamPipeOptions = {
	?preventAbort:Bool,
	?preventCancel:Bool,
	?preventClose:Bool,
	?signal:Dynamic
};
