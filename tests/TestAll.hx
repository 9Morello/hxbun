package tests;

import utest.Runner;
import utest.ui.Report;
import recordMacrosTests.RecordMacrosSqliteTest;
import recordMacrosTests.TestSqliteConnection;
import recordMacrosTests.TestSqliteResultSet;
import jsExternTests.TestQueryParser;

class TestAll {
	public static function main() {
		// the short way in case you don't need to handle any specifics
		utest.UTest.run([
			new TestUtilities(),
			new TestChildProcesses(),
			new TestHxnodejsCompatibility(),
			new TestBunShell(),
			new TestFetch(),
			new TestFileSystem(),
			new TestDatabase(),
			new RecordMacrosSqliteTest("test.db"),
			new TestSqliteConnection(),
			new TestSqliteResultSet(),
			new TestQueryParser()
		]);
	}
}
