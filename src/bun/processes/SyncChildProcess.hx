package bun.processes;

import js.lib.ArrayBuffer;
import haxe.io.BytesData;
import haxe.extern.EitherType;
/**
 * A blocking synchronous child process, instantiated by the `Bun.spawnSync` function.
 **/
interface SyncChildProcess {
	/**
	 * The process ID of the child process.
	 **/
	public var pid(default, never):Int;

	/**
	 * Whether the process has exited successfully or not.
	 **/
	public var success(default, never):Bool;

	/**
	 * Standard output from the process as an ArrayBuffer.
	 **/
	public var stdout(default, never):Null<EitherType<ArrayBuffer, BytesData>>;

	/**
	 * Standard error from the process as an ArrayBuffer.
	 **/
	public var stderr(default, never):Null<EitherType<ArrayBuffer, BytesData>>;

	/**
	 * The exit code of the process.
	 **/
	public var exitCode(default, never):Int;

	/**
	 * Resource usage information for the subprocess.
	 **/
	public var resourceUsage(default, never):ResourceUsage;

	/**
	 * The signal code if the process was terminated by a signal.
	 **/
	public var signalCode(default, never):Null<String>;

	/**
	 * Whether the process exited due to a timeout.
	 **/
	public var exitedDueToTimeout(default, never):Null<Bool>;
}