package tests;

import utest.Test;
import utest.Assert;
import sys.FileSystem;
import sys.io.File;

class TestHxnodejsCompatibility extends Test {
	function testFileSystemFunctions() {
		FileSystem.createDirectory("some_dir");
		Assert.isTrue(FileSystem.exists("some_dir"));
		FileSystem.deleteDirectory("some_dir");
		Assert.isFalse(FileSystem.exists("some_dir"));
	}
}
