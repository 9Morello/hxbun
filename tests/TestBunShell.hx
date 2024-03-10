package tests;

import utest.Test;
import utest.Assert;
import bun.Shell;

class TestBunShell extends Test {
	function testShellEcho(async:utest.Async) {
		final phrase = "$`echo 'Hello World'`";
		final expectedOutput = "Hello World\n";

		final cmd = Shell.run(phrase).then(result -> {
			Assert.equals(expectedOutput, result.stdout.toString());
			async.done();
		});
	}
}
