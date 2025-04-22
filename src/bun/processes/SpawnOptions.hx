package bun.processes;

import haxe.io.BytesData;
import helpers.EitherOf.EitherOf5;
import haxe.extern.EitherType;

/**
 * Options for spawning a child process
 **/
typedef SpawnOptions = {
	?cwd:String,
	?env:Dynamic<String>,
	?stdin:SpawnIO,
	?stdout:SpawnIO,
	?stderr:SpawnIO,
	?onExit:(subprocess:ChildProcess, exitCode:Null<Int>, signalCode:Null<AbortSignal>, ?error:Dynamic) -> Void,
	?ipc:(message:Any, subprocess:ChildProcess) -> Void,
	?serialization:EitherType<String, IPCMessageSerializationType>,
	?windowsHide:Bool,
	?windowsVerbatimArguments:Bool,
	?argv0:String,
	?signal:AbortSignal, // AbortSignal
	?timeout:Int,
	?killSignal:EitherType<String, Int>,
	?maxBuffer:Int
}


/**
 * Type for process stdio configuration.
 **/
typedef SpawnIO = EitherOf5<String, bun.BunFile, js.lib.ArrayBufferView, Int, BytesData>;