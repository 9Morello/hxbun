package tests;

import haxe.Json;
import bun.BunFile;
import utest.Test;
import utest.Assert;
import utest.Async;
import js.lib.Uint8Array;
import bun.Database;

using ResultTools;

class TestDatabase extends Test {
	function testReadAndWrite() {
		final db = new Database();
		db.queryRaw('CREATE TABLE Users (id INTEGER PRIMARY KEY AUTOINCREMENT, nickname VARCHAR(32) NOT NULL, age INT);').run();
		final insertStatement = db.query('INSERT INTO Users (nickname, age) VALUES (?1, ?2)');
		insertStatement.map(statement -> statement.run("Baki", 18));

		final statementResult = db.query('SELECT * FROM Users');
		Assert.isTrue(statementResult.isOk());
		var selectStatement:Statement<User> = statementResult.getVal();
		var results:Array<User> = selectStatement.all();
		Assert.equals(1, results.length);
		Assert.equals("Baki", results[0].nickname);
		Assert.equals(18, results[0].age);

		insertStatement.map(statement -> statement.run("Retsuo Kaiou", 30));
		var newResults = selectStatement.all();
		Assert.equals(2, newResults.length);
		Assert.equals("Baki", newResults[0].nickname);
		Assert.equals("Retsuo Kaiou", newResults[1].nickname);
		Assert.equals(30, newResults[1].age);
	}

	function testInvalidQuery() {
		final db = new Database();
		final invalidQuery = db.query('dsjhvgdeswhjkfgbdsf');
		Assert.isFalse(invalidQuery.isOk());
	}

	function testSaveToDisk(async:utest.Async) {
		var db = new Database();
		db.query('CREATE TABLE IF NOT EXISTS Users (id INTEGER PRIMARY KEY AUTOINCREMENT, nickname VARCHAR(32) NOT NULL, age INTEGER NOT NULL);')
			.map(statement -> statement.all());
		db.query('INSERT INTO Users (nickname, age) VALUES (?1, ?2)').map(statement -> {
			statement.run("Baki", 18);
			statement.run("Jotaro", 40);
		});

		var file:BunFile = Bun.file("serialized_db");
		Bun.writeBytesData(file, db.serialize()).then(_ -> {
			file.arrayBuffer().then((rawDbData) -> {
				var rawDataAsUInt8Array = new Uint8Array(rawDbData);
				var newDbInstance = Database.deserialize(rawDataAsUInt8Array);
				var selectStatement:Statement<User> = newDbInstance.query('SELECT * FROM Users').getVal();
				var results:Array<User> = selectStatement.all();
				Assert.equals(2, results.length);
				Assert.equals("Baki", results[0].nickname);
				Assert.equals(18, results[0].age);
				Assert.equals("Jotaro", results[1].nickname);
				Assert.equals(40, results[1].age);
				async.done();
			});
		});
	}
}

private typedef User = {id:Int, nickname:String, ?age:Int}
