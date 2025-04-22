package bun.processes;

import js.lib.Promise;
import haxe.extern.EitherType;
import bun.FileSink;
import bun.ReadableStream;
/**
 * A subprocess spawned by Bun.spawn(). This interface represents an asynchronous child process.
**/
interface ChildProcess {
	/**
	 * The process ID of the child process.
	**/
	public var pid(default, never):Int;

	/**
	 * The exit code of the process. If the process hasn't exited, it's `null`.
	**/
	public var exitCode(default, never):Null<Int>;

	/**
	 * The signal code if the process was terminated by a signal.
	**/
	public var signalCode(default, never):Null<AbortSignal>;

	/**
	 * Standard input stream for the subprocess.
	**/
	public var stdin(default, never):Null<EitherType<FileSink, Int>>;

	/**
	 * Standard output stream from the subprocess.
	**/
	public var stdout(default, never):Null<EitherType<ReadableStream<js.lib.Uint8Array>, Int>>;

	/**
	 * Standard error stream from the subprocess.
	**/
	public var stderr(default, never):Null<EitherType<ReadableStream<js.lib.Uint8Array>, Int>>;

	/**
	 * Combined stdout and stderr as a readable stream.
	**/
	public var readable(default, never):Null<EitherType<ReadableStream<js.lib.Uint8Array>, Int>>;

	/**
	 * Promise that resolves when the process exits, with the exit code.
	**/
	public var exited(default, never):Promise<Int>;

	/**
	 * Whether the subprocess has been killed.
	**/
	public var killed(default, never):Bool;

	/**
	 * Kills the subprocess with the given exit code or signal.
	 * @param exitCodeOrSignal Optional exit code or signal to terminate the process.
	**/
	public function kill(?exitCodeOrSignal:EitherType<Int, AbortSignal>):Void;

	/**
	 * Makes the subprocess block the event loop from exiting.
	**/
	public function ref():Void;

	/**
	 * Allows the event loop to exit even if the subprocess is still running.
	**/
	public function unref():Void;

	/**
	 * Sends a message to a Bun/Node.js child process via IPC.
	 * Only works if the subprocess was spawned with an ipc handler.
	 * @param message The message to send to the child process.
	**/
	public function send(message:Any):Void;

	/**
	 * Closes the IPC channel between parent and child process.
	**/
	public function disconnect():Void;

	/**
	 * Gets resource usage information for the subprocess.
	 * @return ResourceUsage or undefined if not available.
	 **/
	public function resourceUsage():Null<ResourceUsage>;
}