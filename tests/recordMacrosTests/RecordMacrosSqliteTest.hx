package recordMacrosTests;

import bun.Database;

class RecordMacrosSqliteTest extends CommonDatabaseTest {
	var dbPath:String;

	public function new(dbPath) {
		this.dbPath = dbPath;
		super();
	}

	override function connect() {
		sys.db.Manager.cnx = new Database(dbPath).getConnection();
	}
}
