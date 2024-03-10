package bun;

import js.lib.ArrayBuffer;

interface Subprocess {
	/**
	 * The process ID of the child process.
	**/
	public var pid(default, never):Int;

	/**
	 * The exit code of the process. If the process hasn't exited it, it's `null`.
	**/
	public var exitCode(default, never):Null<Int>;

	public var signalCode(default, never):Null<Int>;
}

/**
 * A blocking synchronous Subprocess, instantiated by the `Bun.spawnSync` function.
**/
interface SyncSubprocess {
	/**
	 * The process ID of the child process.
	**/
	public var pid(default, never):Int;

	/**
	 * Whether the process has exited successfully or not.
	**/
	public var success(default, never):Bool;

	public var stdout(default, never):Null<ArrayBuffer>;

	public var stderr(default, never):Null<ArrayBuffer>;
}
