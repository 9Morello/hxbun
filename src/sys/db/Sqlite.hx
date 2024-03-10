package sys.db;

/**
 * Small class that provides a single static function that opens
 * an Sqlite database, and returns a connection.
**/
class Sqlite {
	/**
	 * Opens a SQLite database on the specified path, and returns a `Connection` instance. 
	 * @param file 
	 * @return Connection
	**/
	public static function open(file:String):Connection {
		return new bun.Database(file).getConnection();
	}
}
