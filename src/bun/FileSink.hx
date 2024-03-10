package bun;

import haxe.io.BytesData;
import haxe.io.Bytes;
import js.lib.ArrayBuffer;
import js.lib.Promise;
import haxe.extern.EitherType;

/**
 * The FileSink class provides functions for continuously writing data to a file.
**/
extern class FileSink {
	/**
	 * Writes data to a file. Returns the number of bytes written.
	 * @param data 
	 * @return Int
	**/
	public function write(data:EitherType<String, EitherType<BytesData, ArrayBuffer>>):Int;

	/**
	 * Writes data to a file. Returns the number of bytes written.
	 * @param data the data to be written as a `String`. 
	 * @return Int
	**/
	public inline function writeString(data:String):Int {
		return write(data);
	};

	/**
	 * Writes data to a file. Returns the number of bytes written.
	 * @param data the data to be written as `Bytes`. 
	 * @return Int
	**/
	public inline function writeBytes(data:Bytes):Int {
		return write(data.getData());
	};

	/**
	 * Flushes the internal buffer, commiting the data to disk.
	 * @return EitherType<Int, Promise<Int>>
	**/
	public function flush():EitherType<Int, Promise<Int>>;

	/**
	 * Close the file descriptor. This also flushes the internal buffer.
	**/
	public function end():EitherType<Int, Promise<Int>>;
}
