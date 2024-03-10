package tests;

import helpers.ResultPromise;
import js.lib.Promise;
import result.Result;
import sys.io.File;
import sys.FileSystem;
import utest.Assert;
import utest.Test;

using ResultTools;

class TestFileSystem extends Test {
	final fileName = "testfile" + Std.string(Std.random(999));
	final testFileContent = "some content";

	@:timeout(300) function testWrite(async:utest.Async) {
		final ioResultPromise = Bun.writeString(fileName, testFileContent);
		ioResultPromise.then(ioResult -> {
			Assert.isTrue(ioResult.isOk());
			Assert.equals(testFileContent.length, ioResult.getVal());
			async.done();
		});
	}

	@:timeout(300) @:depends(testWrite) function testRead(async:utest.Async) {
		final bunFile = Bun.file(fileName);
		bunFile.text().then(ioResult -> {
			switch ioResult {
				case Some(fileContent):
					Assert.equals(testFileContent, fileContent);
					async.done();
				case None:
					Assert.fail("failed to read file content");
					async.done();
			}
		});
	}

	@:depends(testRead) function testDelete() {
		Assert.isTrue(FileSystem.exists(fileName));
		FileSystem.deleteFile(fileName);
		Assert.isFalse(FileSystem.exists(fileName));
	}
}
