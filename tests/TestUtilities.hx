package tests;

import utest.Test;
import utest.Assert;
import utest.Async;
import js.lib.Uint8Array;
import Bun;

class TestUtilities extends Test {
	function testVersionCheck() {
		Assert.equals("1.0.35", Bun.version);
	}

	function testRevisionCheck() {
		Assert.isOfType(Bun.revision, String);
	}

	function testMainPathCheck() {
		Assert.isOfType(Bun.main, String);
	}

	function testWhich() {
		final whichBun = Bun.which("bun");
		Assert.isTrue(StringTools.contains(whichBun, "bun"));
		final gibberishFileName = "zskdfjvgkjsfdgvjfdsgh";
		Assert.equals(null, Bun.which(gibberishFileName));
	}

	function testDeepEquals() {
		final a = {entries: [1, 2]};
		final b = {entries: [1, 2], extra: js.Syntax.code("undefined")};
		Assert.isTrue(Bun.deepEquals(a, b));
		Assert.isFalse(Bun.deepEquals(a, b, true));
	}

	function testGzipSync() {
		var stringBuf = new StringBuf();
		var i = 0;
		while (i++ < 100)
			stringBuf.add("hello");
		final str = stringBuf.toString();
		final buf:Uint8Array = Uint8Array.from(str);
		final compressed:Uint8Array = Bun.gzipSync(buf);

		Assert.equals(500, buf.length); // => Uint8Array(500)
		Assert.equals(26, compressed.length); // => Uint8Array(26)
	}

	@:timeout(500) function testPassword(async:utest.Async) {
		final superSecretPassword = "Haxe ❤️ Bun";
		Bun.password.hash(superSecretPassword).then((hash) -> {
			Bun.password.verify(superSecretPassword, hash).then((result) -> {
				Assert.isTrue(result);
				async.done();
			});
		});
	}

	function testPasswordSync() {
		final superSecretPassword = "Haxe ❤️ Bun";
		final hash = Bun.password.hashSync(superSecretPassword);
		Assert.isTrue(Bun.password.verifySync(superSecretPassword, hash));
	}

	function testEnviroment() {
		final myEnvValue = Bun.env.MYENV;
		Assert.equals("TEST", myEnvValue);

		final myUndefinedEnvValue = Bun.env.someUndefinedEnviromentVariable;
		Assert.isNull(myUndefinedEnvValue);
	}

	// function testGunzipSync() {}
}
