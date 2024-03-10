<div align="center">

![hxbun](hxbun.png)

</div>

# hxbun

This WIP haxelib includes mostly hand-written externs for [Bun](https://bun.sh/), an extremely fast JavaScript runtime. It can be used to access Bun's APIs using Haxe's JavaScript target.
You can optionally use it together with [hxnodejs](https://github.com/HaxeFoundation/hxnodejs). Bun implements the majority of Node's APIs and most
code that uses `hxnodejs` externs should just work too.

This haxelib has been tested on GNU/Linux. It should work normally on macOS. Windows `may` work once Bun officially supports it, but using WSL is preferred.

Credits:

* [Bun](bun.sh/)
* [hxnodejs](https://github.com/HaxeFoundation/hxnodejs)
* [record-macros](https://github.com/HaxeFoundation/record-macros)
* [jsImport by back2dos](https://github.com/back2dos/jsImport/)

## Features

* Built-in docs for most types, giving developers a good experience in a supported editor
* Wrappers that make native Bun APIs more convenient to use from Haxe, for example, by allowing you to pass `Bytes` or `BytesData` types to functions that make sense to use them with
* Most functions have non-throwing wrappers that return `Option` or `Result` types, including a Promise equivalent of each. In case you don't want to use them, raw functions are exposed if you want to handle errors yourself.
* Mostly compatible with existing `hxnodejs` projects, thanks to Bun's work in implementing most of Node.js APIs.
* Most classes are unit tested on the Haxe side using the [`utest`](https://github.com/haxe-utest/utest/) library.

## Installation

### Install Bun

First, make sure you have Bun installed in your computer. You can install it on macOS, GNU/Linux and WSL with the following command:

`curl -fsSL https://bun.sh/install | bash`

### Install hxbun

Then, you can install this library directly from Git:

`haxelib git hxbun https://github.com/9Morello/hxbun`

You can also a release from [Haxelib](https://lib.haxe.org/):

`haxelib install hxbun`

## Usage

This library offers a top-level `Bun` class, which contains general purpose utilities, and a few classes inside the `bun` package.

### Spinning up a web server

You can start a basic web server with the following snippet of code:

```haxe
import js.html.Response;
import js.html.Request;

class Main {
	static function main() {
		// Bun defaults to using port 3000, if no port is specified
		Bun.serve((req) -> {
			return new Response("Hello, world!");
		});
	}
}
```
Navigating to `http://localhost:3000` in your browser will correctly display "Hello, world!" to you.
`Bun.serve` can be called in multiple ways. The above example passes a function that handles a request, but you can pass an object to gain access to more options:

```haxe
import js.html.Response;
import js.html.Request;

class Main {
	static function main() {
		// specifies which port you want to use
		Bun.serve({
			fetch: (req:Request) -> {
				return new Response("Hello, world!");
			},
			port: 4000
		});
	}
}
```

In the above example, we passed an object with two parameters: a `fetch` function, which handles a `Request`, and the `port` the server will use to listen to connections.

`Bun.serve` has a safe variant called `Bun.serveSafe`, which never throws, and wraps the returning value in a `Result` type instead:

```haxe
	final server = Bun.serveSafe({
		fetch: (req:Request) -> {
			return new Response("Hello, world!");
		},
		port: 3000
	});

	switch (server) {
		case Ok(_):
			trace('Yay, server is running!');
		case Error(e):
			trace('Caught an error: $e');
	}
```

You can handle different API endpoints in your web server by matching against the request URL:

```haxe
class Main {
	static function main() {
		final server = Bun.serveSafe({
			fetch: (req:Request) -> {
				final path = new URL(req.url).pathname;
				trace(path);
				switch (path) {
					case '/':
						return new Response("Hello, world!");
					case '/some_api_endpoint':
						return new Response('Some complex data');
					default:
						return new Response('invalid endpoint', {status: 404});
				}
			},
			port: 3000
		});
	}
}
```

You can use a routing library if you want more built-in features (like parsing query parameters).

### Creating a WebSocket server

Bun has a great API for creating WebSocket servers, which you can leverage to build your own protocols on top of it.

To create a WebSocket server, you will also use `Bun.serve`, but your `fetch` function will handle the upgrade from HTTP to WebSocket:

```haxe
import Bun.Server;
import js.html.Response;
import js.html.Request;

class Main {
	static function main() {
		Bun.serve({
			fetch: (req:Request, server:Server) -> {
				server.upgrade(req);
				return null;
			},
			websocket: {
				open: function(ws) {
					ws.sendString('Hi, from bun server!');
				},
				message: function(ws, msg) {
					trace('Message received in bun server: ' + msg);
				}
			}
		});
	}
}
```

The `websocket` property receives an object with up to four function handlers: 
* `open`: called when a new WebSocket connection is estabilished
* `message`: called when the WebSocket server receives a message from a client. The message can be either a `String` or a `BytesData`.
* `close`: called when a connection is closed. You can pass an error code (`Int`) and a reason (`String`) for closing the connection.
* `drain`: Called when a connection was previously under backpressure (in other words, it had too many queued messages), but is now ready to receive more data.

WebSocket servers accept type parameters, and you can attach relevant data to each connection. To do that, pass a structure as the second argument to the `server.upgrade` call, and add the apropriate type parameters:

```haxe
import bun.WebSocketServer;
import Bun.Server;
import js.html.Request;
import js.lib.Date;

typedef WebSocketData = {
	createdAt:Date,
	authToken:String
};

class Main {
	static function main() {
		Bun.serve({
			fetch: (req:Request, server:Server<WebSocketData>) -> {
				server.upgrade(req, {
					data: {
						createdAt: new Date(),
						authToken: req.headers.get('Authorization')
					}
				});
				return null;
			},
			websocket: {
				open: function(ws) {
					ws.sendString('Hi, from bun server!');
				},
				message: function(ws:WebSocketServer<WebSocketData>, msg) {
					trace('Date this connection was made: ${ws.data.createdAt}');
					trace('Message received in bun server: ' + msg);
				}
			}
		});
	}
}
```

The data you added will be available inside the function handlers, on the `ws.data` property. If you don't use type parameters, then `ws.data` is `Any`.

### Reading and writing to a SQLite database

Bun has built-in support for SQLite, and you can use it from Haxe. You can start working with an in-memory database like this:

```haxe
import bun.Database;

function initMyDatabase():Database {
	var db = new Database(":memory:");
	return db;
}

```

Passing no arguments, an empty string, or the `:memory:` to the `Database` constructor will keep the database in-memory. If you wish to open an existing SQLite file, you can either pass the file name as a `String`, or the contents of that file itself as a `BytesData` / `Uint8Array` instance.

To run queries in your database, you can use the `query` function to create a `Statement` instance, then use `run`/`get`/`all` on that `Statement`, depending on what you want to do:

```haxe
import bun.Database;
import haxe.ds.Option;

using ResultTools;

typedef User = {
	nickname:String, 
	age:Int
};

function doSomeDatabaseOperations():Option<Database> {
	final db = new Database(":memory:");
	
	// Creates a table if it doesn't exist
	final initialQueryResult = db.query('CREATE TABLE IF NOT EXISTS Users (id INTEGER PRIMARY KEY AUTOINCREMENT, nickname VARCHAR(32) NOT NULL, age INT);');

	// checks if the `query` command returned an error or not
	switch (initialQueryResult) {
		case Ok(initialQuery):
			initialQuery.run();
		case Error(_):
			return None;
	}
	
	// Creates a statement that inserts a new user into said table.
	db.query('INSERT INTO Users (nickname, age) VALUES (?1, ?2)').map(statement -> {
		// Thanks to the `ResultTools` static extension, we only attempt to insert data if the query is valid
		// Uses the above statement to insert elements into the database.
		// Using the ?1, ?2 placeholders makes bun escape your queries by default.
		insertStatement.runSafe("Baki", 18);
		insertStatement.runSafe("Jotaro", 40);
	});
	 

	
	// Fetch results from your DB, and prints them to the terminal. This API is synchronous.
	db.query('SELECT * FROM Users').map(selectStatement -> {
		final results:Array<User> = selectStatement.all();
		trace(results); 
	});
	
	return Some(db);
}
	
```

Statements also have raw variants of their functions that aren't wrapped as `Option` or `Result`. Those functions may throw.

```haxe
		var db = new Database("mydb.sqlite");
		var insertStatement = db.queryRaw('INSERT INTO Users (nickname, age) VALUES (?1, ?2)');

		// runs fine
		var result = insertStatement.run("Baki", 18);
		// throws an error
		var result = insertStatement.run("Baki", "18");
```

It's recommended to use `runSafe`, `getSafe` and `allSafe` instead of their raw variants to avoid runtime crashes.

### Using record-macros as your ORM

[record-macros](https://github.com/HaxeFoundation/record-macros) is an ORM developed by the Haxe Foundation. hxbun implements the `Connection` interface and makes it usable with Bun's built-in SQLite database.

```haxe
final connection = sys.db.Sqlite.open("my_database.sqlite"); // final connection = new bun.Database("my_database.sqlite").getConnection() also works
sys.db.Manager.cnx = cnx;
sys.db.Manager.initialize();
```


You can find documentation explaining how to use it in the [record-macros repo](https://github.com/HaxeFoundation/record-macros) - besides the way you connect to it, it basically works the same way as it does for other targets that support it. Make sure you install record-macros from Git directly - the haxelib version is outdated as of March 2024.

hxbun runs record-macros's full test suit, which is embedded in this repository, inside the `tests` folder.

### Fetching data from third party APIs

Bun implements the `fetch` Web API, and hxbun exposes it. You can use it instead of Haxe's standard Http class to make requests to other HTTP servers.

```haxe
import Bun.fetch;

function fetchSomething() {
	final fetchPromise = fetch('https://pokeapi.co/api/v2/pokemon/ditto').then(v -> {
		switch (v) {
			case Ok(response): response.json().then(jsonObj -> {
					trace('Response from API: ${haxe.Json.stringify(jsonObj)}');
				});

			case Error(_):
				trace("Api call failed");
		}
	});
}
```

You can use `fetchJson` to automatically parse the response as JSON:

```haxe
import Bun.fetchJson;

function fetchJsonObject() {
	final jsonObjPromise = fetchJson('https://pokeapi.co/api/v2/pokemon/ditto').then(result -> {
		switch (result) {
			case Ok(rawObject):
				trace('Is a Ditto: ${(rawObject : PokeApiType).name == "ditto"}');

			case Error(_):
				trace("Api call failed");
		}
	});
}
```

`fetchJson` types the resulting object as `Any` when it results in a successful API call. You must assign it a proper type (like in the example above) to be able to access its fields, ideally using a validation library to ensure its fields are actually valid. [Tink Validation](https://github.com/haxetink/tink_validation/) is a haxelib that does that well, and the test suit for hxbun contains an example showing how to use it.

`Bun.fetch` and `Bun.fetchJson` wrap the `fetch` calls into a `PromiseResult` type, which is a Promise that returns a `Result` and never rejects. You can opt-out of this built-in error handling by calling `Bun.fetchRaw` instead, which behaves much like `fetch` in JS runtimes.