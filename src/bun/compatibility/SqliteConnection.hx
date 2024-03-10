package bun.compatibility;

import datetime.DateTime;
import haxe.ds.List;
import haxe.io.Bytes;
import sys.db.ResultSet;

using StringTools;

/**
 * This class is a wrapper around `bun.Database` that partially implements the `Connection` interface.
 * The main use case for this is if you need the `Connection` interface for a reason,
 * like for example, using the record-macros ORM. Otherwhise, using `bun.Database` is recommended.
**/
class SqliteConnection implements sys.db.Connection {
	private var db:Database;
	private var _lastInsertId:Int;
	private var filename:String;

	public function new(db:Database) {
		this.db = db;
		this.filename = db.filename;
		_lastInsertId = -1;
	}

	private function myTrace(v:Dynamic):Void {
		trace(v);
	}

	public function close() {
		db.close();
	}

	public function dbName():String {
		return "SQLite";
	}

	public function lastInsertId():Int {
		return db.queryRaw("SELECT last_insert_rowid()").values()[0][0];
	}

	public function request(sql:String):ResultSet {
		try {
			var bytes = Bytes.ofString(sql);
			var bytesData = bytes.getData();

			var i = 0;

			while (i < bytes.length) {
				var b1 = Bytes.fastGet(bytesData, i);
				if (b1 != '"'.code) {
					i++;
					continue;
				}
				if (i < bytes.length - 1) {
					var b2 = Bytes.fastGet(bytesData, i + 1);
					if (b2 != '"'.code) {
						bytes.set(i, "'".code);
						i++;
					}
				}
				i++;
			}

			sql = bytes.toString();

			final data = db.queryRaw(sql).all();
			final lastInsertedRowId:Int = lastInsertId();
			return new ResultSetImpl(data, lastInsertedRowId);
		} catch (e:String) {
			throw "Error while executing " + sql + " (" + e + ")";
		}
	}

	public function escape(s:String):String {
		return s.split("'").join("''");
	}

	public function quote(s:String):String {
		return "'" + s.split("'").join("''") + "'";
	}

	public function rollback():Void {
		request("ROLLBACK");
	}

	public function startTransaction():Void {
		request("BEGIN TRANSACTION");
	}

	public function commit():Void {
		request("COMMIT");
	}

	public function addValue(s:StringBuf, v:Dynamic) {
		switch (Type.typeof(v)) {
			case TNull:
				s.add(v);

			case TBool:
				s.add(v ? 1 : 0);

			case TClass(String):
				var stringValue = Std.string(v);
				s.add(quote(stringValue));

			case TClass(Date):
				v = cast(v, js.lib.Date);
				s.add(dateToString(v));

			case TClass(Bytes):
				s.add(quote((v : haxe.io.Bytes).toString()));

			default:
				s.add(v);
		}
	}

	private inline function dateToString(date:Date):String {
		var dateTime = DateTime.fromDate(date);
		var fakeUtc = dateTime.utc();
		var difference = dateTime - fakeUtc;
		dateTime += difference;
		return quote(dateTime.format('%F %T'));
	}
}

/**
 * Partial implementation of the `ResultSet` interface for compatibility purposes.
**/
private class ResultSetImpl implements sys.db.ResultSet {
	private var data:List<Dynamic>;

	private var dataSource:Array<Dynamic>;

	private var currentRow(get, null):Dynamic;

	private var columns:Array<String>;

	public var length(get, null):Int;

	public var nfields(get, null):Int;

	public var lastInsertRowid:Int;

	public function new(dataSource:Dynamic, lastInsertRowid:Any) {
		this.dataSource = cast(dataSource, Array<Dynamic>);
		this.lastInsertRowid = lastInsertRowid;

		data = new List();

		for (element in this.dataSource) {
			data.add(element);
		}

		columns = Reflect.fields(currentRow);
	}

	private function get_length():Int {
		return data.length;
	}

	private function get_nfields():Int {
		if (data.first() == null)
			return 0;

		return Reflect.fields(data.first()).length;
	}

	public function getFieldsNames():Null<Array<String>> {
		if (data.first() == null)
			return null;

		return Reflect.fields(data.first());
	}

	public function getFloatResult(columnPosition:Int):Float {
		return Std.parseFloat(getResult(columnPosition));
	}

	public function getIntResult(columnPosition:Int):Int {
		return Std.parseInt(getResult(columnPosition));
	}

	public function getResult(columnPosition:Int):String {
		return Std.string(Reflect.field(data.first(), columns[columnPosition]));
	}

	public function hasNext():Bool {
		return (data.length > 0);
	}

	public inline function next():Dynamic {
		return data.pop();
	}

	public function results():List<Dynamic> {
		return data;
	}

	private inline function get_currentRow():Dynamic {
		return data.first();
	}
}
