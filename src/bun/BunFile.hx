package bun;

import helpers.OptionPromise;
import js.lib.Error;
import js.lib.Promise;
import haxe.extern.EitherType;

/**
 * A BunFile represents a lazily-loaded file. initializing it does not actually read the file from disk.
 * You can intantiate it by calling `Bun.file("your_file_name")`.
 * The functions provide by this class are heavily optimized and represent the preferred way of
 * operating on disk files using Bun. 
**/
extern class BunFile extends js.html.Blob {
	/**
	 * Gets the file content as a string.
	 * @return Promise<String>
	**/
	@:native("text") function textRaw():Promise<String>;

	/**
	 * Gets the file content as a string.
	 * @return OptionPromise<String>
	**/
	inline function text():OptionPromise<String> {
		return wrapPromise(textRaw());
	};

	/**
	 * Gets the file content as a ReadableStream.
	 * @return Promise<ReadableStream>
	**/
	function stream():Promise<ReadableStream>;

	/**
	 * Gets the file content as an ArrayBuffer.
	 * @return Promise<String>
	**/
	function arrayBuffer():Promise<js.lib.ArrayBuffer>;

	/**
	 * Close the file descriptor. This also flushes the internal buffer.
	**/
	function end(?error:Error):EitherType<Int, Promise<Int>>;

	/**
	 * Flush the internal buffer, committing the data to disk or the pipe.
	**/
	function flush():EitherType<Int, Promise<Int>>;

	/**
	 * Gets the file content as an structure.
	 * @return Promise<String>
	**/
	@:native("json") extern overload function jsonRaw():Promise<Any>;

	/**
	 * Asyncronously tries to read the file contents as an structure. Returns `Option.None` if that fails for any reason.
	 * @return OptionPromise<String>
	**/
	inline function json():OptionPromise<Any> {
		return wrapPromise(jsonRaw());
	};

	/**
	 * Gets a `FileSink` for the current file. A `FileSink` provides an API to incrementall write content to a file.
	 * @param params An optional object containing the `highWaterMark` field. 
	 * If provided, this function will preallocate an internal buffer of this size. This can significantly improve performance when the chunk size is small.
	 * @return FileSink
	**/
	function writer(?params:{?highWaterMark:Int}):FileSink;
}
