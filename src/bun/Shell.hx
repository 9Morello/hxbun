package bun;

import js.Syntax;
import js.lib.Promise;
import js.node.buffer.Buffer;

@:js.customImport('bun', '$', '$') extern class Shell {
	/**
	 * Run a command using Bun's built-in cross-platform shell. Accepts Bash-like syntax, and
	 * should have the same behavior on Windows, Linux and macOS.
	 * Bun's Shell is under development. This API is considered unstable and still in alpha state.
	 * @param the full command you want to run, as a String. Must be a constant value at compile time.
	 * @return ShellOutput
	**/
	public static inline function run(command:String):Promise<ShellOutput> {
		return Syntax.code(command);
	}

	/**
	 * Run a command using Bun's built-in cross-platform shell. Same as `run`, but
	 * it doesn't print the output to stdout.
	 * Bun's Shell is under development. This API is considered unstable and still in alpha state.
	 * @param the full command you want to run, as a String.
	 * @return ShellOutput
	**/
	public static inline function runQuiet(command:String):Promise<ShellOutput> {
		return Syntax.code("$`{0}`.quiet()", command);
	}

	/**
	 * Run a command using Bun's built-in cross-platform shell, and get the output back
	 * as a `String`. Running commands this way won't print its output to stdout.
	 * @param the full command you want to run, as a String.
	 * @return ShellOutput
	**/
	public static inline function runAndFetchResult(command:String):Promise<String> {
		return Syntax.code("$`{0}`.text()", command);
	}

	/**
	 * Change the current working directory of the shell.
	 * @param newCwd 
	 * @return ShellResult
	**/
	public static function cwd(newCwd:String):ShellOutput;

	/**
	 * Receives an anonymous structure, and uses its fields to set
	 * environment variables for the user. For example, passing 
	 * `{BUN: "something"}` to this function would set the environment variable
	 * BUN to "something" inside this shell.
	 * 
	 * Each field value should be a string.
	 * @param envVariables 
	 */
	public overload static function env(?envVariables:Dynamic):Void;

	/**
	 * Receives a <String, String> Map, and uses its key/values to set
	 * environment variables for the user.
	 * @param envVariables 
	 */
	public overload static inline function env(envVariablesMap:haxe.ds.Map<String, String>):Void {
		final envVarsObject = {};
		for (key => value in envVariablesMap) {
			Reflect.setField(envVarsObject, key, value);
		}
		env(envVarsObject);
	};

	private function new();
}

extern class ShellOutput {
	private function new();

	public var stdout(default, never):Buffer;
	public var stderr(default, never):Buffer;
	public var exitCode(default, never):Int;

	/**
	 * Change the current working directory of the shell.
	 * @param newCwd 
	 * @return ShellResult
	 */
	public function cwd(newCwd:String):ShellOutput;
}
