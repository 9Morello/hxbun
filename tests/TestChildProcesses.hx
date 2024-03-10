package tests;

import js.Syntax;
import utest.Test;
import utest.Assert;
import utest.Async;
import js.lib.Uint8Array;
import Bun;

@:js.customImport(@star "node:fs") private extern class FileSystem {
	static function existsSync(file:String):Bool;
	static function unlinkSync(file:String):Void;
}

class TestChildProcesses extends Test {
	function testSpawningProcessesSync() {
		// this relies on Bun's node compatibility layer
		final process = Bun.spawnSync(["touch", "some_random_file"]);
		final fileExists:Bool = FileSystem.existsSync("some_random_file");
		Assert.isTrue(fileExists);
		FileSystem.unlinkSync("some_random_file");
	}
}
