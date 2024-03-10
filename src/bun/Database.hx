package bun;

import bun.compatibility.SqliteConnection;
import result.Result;
import haxe.io.BytesData;
import js.lib.Uint8Array;
import haxe.extern.EitherType;

/**
	* High-performance SQLite3 driver for Bun.
	* 
	* As of September 2023, it's the fastest performance of any SQLite driver for JavaScript.
	* This API is synchronous.
	Features include: transactions, parameters (named & positional), prepared statements, and Datatype conversions (`BLOB` becomes `Uint8Array`). 
**/
@:js.customImport("bun:sqlite", "Database") extern class Database {
	/**
		The filename passed when `new Database()` was called.
	**/
	var filename(default, never):String;

	/**
		Whether the database is in a transaction or not.
	**/
	var inTransaction(default, never):Bool;

	/**
		The underlying `sqlite3` database handle

		In native code, this is not a file descriptor, but an index into an array of database handles.
	**/
	var handle(default, never):Int;

	/**
	 * Returns a `Connection` to this database instance.
	 * This only exists for compatibility purposes - you don't need to use the `Connection` instance to operate
	 * in the database.
	**/
	private var connection:sys.db.Connection;

	/**
	 * Returns a `Connection` to this database instance.
	 * This only exists for compatibility purposes - you don't need to use the `Connection` instance to operate
	 * in the database.
	**/
	public inline function getConnection():sys.db.Connection {
		connection = connection ?? new SqliteConnection(this);
		return connection;
	}

	/**
	 * Opens or create a new SQLite3 database. Passing no string to the first argument, an empty string, or `":memory:"` opens an in-memory database.
	 * @param fileNameOrContents the file name as a `String`, or the DB contents as an `Uint8Array`
	 * @param options An optional argument to configure the database. 
	**/
	public function new(fileNameOrContents:EitherType<String, EitherType<Uint8Array, BytesData>> = "", ?options:DatabaseOptions);

	/**
		Close the database connection.

		It is safe to call this method multiple times. If the database is already
		closed, this is a no-op. Running queries after the database has been
		closed will throw an error.
	**/
	public function close():Void;

	/**
		Compiles a SQL query and returns a `Statement` object.

		This **does not execute** the query, but instead prepares it for later
		execution and caches the compiled query if possible.

		The returned values will be typed as the type parameter you pass to this
		function. Those types are **not** enforced by the Database - as in, the
		Database won't perform runtime checks to make sure your statement or Database
		schema matches the type parameter you provided.
	**/
	@:native("query") public function queryRaw<T>(sqlQuery:String):Statement<T>;

	/**
		Compiles a SQL query and returns a `Statement` object.

		This **does not execute** the query, but instead prepares it for later
		execution and caches the compiled query if possible.

		The returned values will be typed as the type parameter you pass to this
		function. Those types are **not** enforced by the Database - as in, the
		Database won't perform runtime checks to make sure your statement or Database
		schema matches the type parameter you provided.
	**/
	@:native("query") public inline function query<T>(sqlQuery:String):Result<Statement<T>, String> {
		try {
			final statement = queryRaw(sqlQuery);
			return Ok(statement);
		} catch (err) {
			return Error(err.toString());
		}
	};

	/**
		bun:sqlite supports SQLite's built-in mechanism for serializing and deserializing databases to and from memory.

		Internally, this calls `sqlite3_serialize`.
	**/
	public function serialize():haxe.io.BytesData;

	/**
	 * Transactions are a mechanism for executing multiple queries in an atomic way; that is, either all of the queries succeed or none of them do.
	 * `transaction()` creates a function that always runs inside a transaction. 
	 * 
	 * *When the function is invoked*, it will begin a new transaction.
	 * 
	 * *When the function returns*, the transaction will be committed.
	 *  
	 * *If an exception is thrown*, the transaction will be rolled back (and the exception will propagate as usual).
	 * 
	 * Returns a transation object. To execute the transaction, use the `call` method. All arguments will be passed through to the wrapped function;
	 * the return value of the wrapped function will be returned by the transaction function.
	 * 
	 * Transactions also come with deferred, immediate, and exclusive versions. 
	 * You can read more about it on the [SQLite official documentation](https://www.sqlite.org/lang_transaction.html#deferred_immediate_and_exclusive_transactions).
	 * 
	 * @param executorFunction The function that will run the transaction.
	 * A typical case is having a function that receives an array, then calls `insert` for every element inside that array.
	 * If such a function runs inside a transation, the changes will only be commited if **all** elements get inserted.
	 * @return -> Transation
	**/
	public function transaction(executorFunction:(...params:Any) -> Null<Any>):Transation;

	/**
		`bun:sqlite` supports SQLite's built-in mechanism for serializing and deserializing databases to and from memory.

		Internally, this calls `sqlite3_deserialize`.
	**/
	public static inline function deserialize(rawDbData:Uint8Array):Database {
		return new Database(rawDbData);
	}
}

/**
 * Options you can pass when creating a `Database` instance.
**/
typedef DatabaseOptions = {
	/**
	 * Opens the database in read-only mode.
	 */
	?readonly:Bool,
	/**
	 * Creates the database file if it doesn't exists.
	 */
	?create:Bool
}

/**
 * A Statement is a _prepared_ query, which means it's been parsed and compiled into an efficient binary form. It can be executed multiple times in a performant way.
 * 
 * Create a statement with the `query` method on your `Database` instance.
**/
extern class Statement<T> {
	/**
		The names of the columns returned by the prepared statement.
	**/
	final columnNames:Array<String>;

	/**
		The number of parameters expected in the prepared statement.
	**/
	final paramsCount:Float;

	private function new();

	/**
	 * Runs a query and gets back the results as an array of objects.
	 * Internally, this calls `sqlite3_reset` and repeatedly calls `sqlite3_step` until it returns `SQLITE_DONE`.
	 * @param ...args 
	 * @return Array<T>
	**/
	public function all(...params:Any):Array<T>;

	/**
	 * Runs a query and gets back the results as an array of objects.
	 * Internally, this calls `sqlite3_reset` and repeatedly calls `sqlite3_step` until it returns `SQLITE_DONE`.
	 * Does the same thing as `all`, but never throws and wraps the error in a `Result` type instead.
	 * @param ...args 
	 * @return Array<T>
	**/
	public inline function allSafe(...params:Any):Result<Array<T>, String> {
		try {
			final value = all(params);
			return value != null ? Ok(value) : Ok([]);
		} catch (e) {
			return Error(e.message);
		}
	}

	/**
	 * Runs a query and gets back the first result as an object.
	 * Internally, this calls `sqlite3_reset` followed by `sqlite3_step` until it no longer returns `SQLITE_ROW`. If the query returns no rows, `null` is returned.
	 * @param ...args 
	 * @return Null<T>
	**/
	public function get(...params:Any):Null<T>;

	/**
	 * Runs a query and gets back the first result as an object.
	 * Internally, this calls `sqlite3_reset` followed by `sqlite3_step` until it no longer returns `SQLITE_ROW`. If the query returns no rows, `null` is returned.
	 * Does the same thing as `get`, but never throws and wraps the error in a `Result` type instead. Empty results are considered an 'error'.
	 * @param ...args 
	 * @return Result<T, String>
	**/
	public inline function getSafe<T>(...params:Any):Result<T, String> {
		try {
			final value = get(params);
			return value != null ? Ok(cast value) : Error('this query returned no results');
		} catch (e) {
			return Error(e.message);
		}
	}

	/**
	 * Runs a query and doesn't get back anything. This is useful for queries schema-modifying queries (e.g. `CREATE TABLE`) or bulk write operations.
	 * Internally, this calls `sqlite3_reset` and calls `sqlite3_step` once. Stepping through all the rows is not necessary when you don't care about the results.
	**/
	@:native("run") public function runRaw(...params:Any):Void;

	/**
	 * Runs a query and doesn't get back anything. This is useful for queries schema-modifying queries (e.g. `CREATE TABLE`) or bulk write operations.
	 * Internally, this calls `sqlite3_reset` and calls `sqlite3_step` once. Stepping through all the rows is not necessary when you don't care about the results.
	 * Does the same thing as `run`, but never throws and wraps the error in a `Result` type instead.
	**/
	public inline function run(params:haxe.Rest<Dynamic>):Result<String, String> {
		try {
			runRaw(params);
			return Ok("");
		} catch (e) {
			return Error(e.message);
		}
	};

	/**
	 * Runs a query and gets back all results as an array of arrays.
	 * @return Array<Array<Any>>
	**/
	public function values(...params:Any):Array<Array<Any>>;

	/**
	 * Destroys a Statement and frees any resources associated with it. 
	 * Once finalized, a Statement cannot be executed again. 
	 * This is called automatically when the prepared statement is garbage collected, but explicit finalization may be useful in performance-sensitive applications.
	 * 
	 * It is safe to call this multiple times. Calling this on a finalized statement has no effect.
	 * 
	 * Internally, this calls `sqlite3_finalize`.
	**/
	public function finalize():Void;

	/**
	 * Prints the expanded SQL query for the prepared statement. This is useful for debugging.
	 * 
	 * Internally, this calls `sqlite3_expanded_sql()` on the underlying `sqlite3_stmt`.
	 * @return String
	**/
	public function toString():String;
}

private interface Transation {
	/**
		uses "BEGIN DEFERRED"
	**/
	dynamic function deferred(args:haxe.Rest<Any>):Void;

	/**
		uses "BEGIN IMMEDIATE"
	**/
	dynamic function immediate(args:haxe.Rest<Any>):Void;

	/**
		uses "BEGIN EXCLUSIVE"
	**/
	dynamic function exclusive(args:haxe.Rest<Any>):Void;

	@:selfCall function call(args:haxe.Rest<Any>):Null<Any>;
}
