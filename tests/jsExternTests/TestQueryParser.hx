package jsExternTests;

import helpers.QueryParser;
import utest.Test;
import utest.Assert;
import Bun;

class TestQueryParser extends Test {
	function testQueryParser() {
		Assert.isTrue(Bun.deepEquals(QueryParser.parse("a=hello&b=world"), {a: "hello", b: "world"}));
	}
}
