import helpers.EitherOf.EitherOf3;
import helpers.EitherOf.EitherOf4;
import sys.net.UdpSocket;
import js.Syntax;
import result.Result;
import haxe.io.BytesData;
import bun.BunFile;
import bun.processes.ChildProcess;
import bun.processes.SyncChildProcess;
import js.lib.ArrayBufferView;
import js.lib.Error;
import js.html.Request;
import js.html.Response;
import haxe.extern.EitherType;
import js.lib.Uint8Array;
import helpers.ResultPromise;
import js.lib.Promise;
import js.node.Buffer;

/**
 * This class exposes a bunch of utility APIs from Bun.
**/
@:native("Bun") extern class Bun {
	/** A read-only string containing the version of the bun CLI that is currently running. **/
	public static var version(default, never):String;

	/** The git commit of Bun that was compiled to create the current bun CLI. **/
	public static var revision(default, never):String;

	/** An absolute path to the entrypoint of the current program **/
	public static var main(default, never):String;

	/** Returns whether the current global scope is the main thread or not. It's always `false` on Workers. **/
	public static var isMainThread(default, never):Bool;

	public static var password(default, never):Password;

	/**
	 * The `end` static field can be used to read and write environment variables.
	 * By default, Bun will read the following files automatically, and make their
	 * values available through this field: `.env`, `env.production` / `.env.development` / `.env.test` (depending on value of `NODE_ENV`)
	 * and `.env.local`.
	**/
	public static var env(default, never):Environment;

	/** Returns a `Promise` that resolves after the given number of milliseconds. **/
	public static function sleep(ms:Float):Promise<Void>;

	/**
	 * A blocking synchronous version of `Bun.sleep`.
	 * @param ms - Time in milliseconds 
	**/
	public static function sleepSync(ms:Float):Void;

	/**
	 * Returns the path to an executable, similar to typing which in your terminal.
	 * By default, Bun looks at the current `PATH` environment variable to determine the path.
	 * 
	 * If the path is not found, this function returns `null`. 
	 * @param bin - The name of the binary you're looking for 
	 * @return String
	**/
	public static function which(bin:String):Null<String>;

	public static function peek<T>(promise:Promise<T>):EitherOf3<T, Promise<T>, js.lib.Error>;

	/**
	 * Opens a file in your default editor.
	 * Bun auto-detects your editor via the $VISUAL or $EDITOR environment variables.
	 * You can optionally pass an object with options to choose which editor to use
	 * (VSCode or Sublime Text), a line and column number.  
	 * @param file 
	 * @param options 
	**/
	public static function openInEditor(file:String, ?options:EditorOptions):Void;

	/**
		* Recursively checks if two objects are equivalent. 
		* A third boolean parameter can be used to enable "strict" mode.
		* 
		final a = { entries: [1, 2] };
		final b = { entries: [1, 2], extra: js.Syntax.code("undefined") };

		Bun.deepEquals(a, b); // strict mode off => true
		Bun.deepEquals(a, b, true); // strict mode on => false
		*  
		* @param object1 First object to compare.
		* @param object2 Second object to compare with the first.
		* @param strict Whether to use strict mode or not.
		* @return Bool
	**/
	public static function deepEquals(object1:Any, object2:Any, ?strict:Bool):Bool;

	/**
		* Escapes the following characters from an input string:

		`"` becomes `&quot;`

		`&` becomes `&amp;`

		`'` becomes `&#x27;`

		`<` becomes `&lt;`

		`>` becomes `&gt;`

		This function is optimized for large input, depending on how much data
		is being escaped and whether there is non-ascii text.
		* @param value The value to escape.
		* @return String the escaped output as a String.
	**/
	public static overload function escapeHTML(value:String):String;

	/**
	 * Creates an instance of `BunFile`, which can be used to make operations
	 * on a file.
	 * This function does not try to read file contents directly. To access its content,
	 * call the `text()` from the `BunFile` instance to try to get it as a `String`.   
	 * @param path 
	 * @return BunFile
	**/
	public static overload function file(path:String):BunFile;

	/**
	 * Syncronously compresses a chunk of data with `zlib` GZIP algorithm.
	 * @param data The buffer of data to compress
	 * @param GzipOptions An optional object containing some compression options.
	 * @return Uint8Array
	**/
	public static function gzipSync(data:Uint8Array, ?GzipOptions:ZlibCompressionOptions):Uint8Array;

	/**
	 * Decompresses a chunk of data with `zlib` GUNZIP algorithm.
	 * @param data The buffer of data to decompress
	 * @return The output buffer with the decompressed data
	**/
	public static function gunzipSync(data:Uint8Array):Uint8Array;

	/**
	 * Syncronously compresses a chunk of data with `zlib` DEFLATE algorithm.
	 * @param data The buffer of data to compress
	 * @param GzipOptions An optional object containing some compression options.
	 * @return Uint8Array
	**/
	public static function deflateSync(data:Uint8Array, ?GzipOptions:ZlibCompressionOptions):Uint8Array;

	/**
	 * Serializes an object to a string exactly as it would be printed by `console.log` on a browser or a terminal.
	 * @param object 
	 * @return String
	**/
	public static function inspect(object:Any):String;

	/**
	 * Returns the number of nanoseconds since the current bun process started, as a number. Useful for high-precision timing and benchmarking.
	 * @return Int
	**/
	public static function nanoseconds():Int;

	/**
	 * Generate a UUIDv7, which is a sequential ID based on the current timestamp with a random component.
	 *
	 * When the same timestamp is used multiple times, a monotonically increasing
	 * counter is appended to allow sorting. The final 8 bytes are
	 * cryptographically random. When the timestamp changes, the counter resets to
	 * a pseudo-random integer.
	 *
	 * @return String The generated UUIDv7 as a hex string
	 *
	 * @example
	 * ```haxe
	 * // Generate UUIDs with default hex encoding
	 * final uuid1 = Bun.randomUUIDv7();
	 * final uuid2 = Bun.randomUUIDv7();
	 * final uuid3 = Bun.randomUUIDv7();
	 * trace(uuid1); // "019706fd-409e-7000-8d6c-fade1c17bb62"
	 * trace(uuid2); // "019706fd-409f-7000-987b-067453b5266b"
	 * trace(uuid3); // "019706fd-409f-7001-82fe-2fffc78c938b"
	 * ```
	**/
	public static overload function randomUUIDv7():String;

	/**
	 * Generate a UUIDv7 with specific encoding, which is a sequential ID based on the current timestamp with a random component.
	 *
	 * @param encoding The encoding format for the UUID
	 * @param timestamp Unix timestamp in milliseconds, defaults to `Date.now()`
	 * @return String The generated UUIDv7 as a string
	 *
	 * @example
	 * ```haxe
	 * // Generate with specific encoding
	 * final hexUuid = Bun.randomUUIDv7(Hex);
	 * final base64Uuid = Bun.randomUUIDv7(Base64);
	 * final base64UrlUuid = Bun.randomUUIDv7(Base64Url);
	 * 
	 * // Generate with custom timestamp
	 * final customTime = new js.lib.Date("2024-01-01");
	 * final timestampedUuid = Bun.randomUUIDv7(Hex, customTime);
	 * ```
	**/
	public static overload function randomUUIDv7(encoding:UUIDv7Encoding, ?timestamp:EitherType<Float, js.lib.Date>):String;

	/**
	 * Generate a UUIDv7 as a Buffer.
	 *
	 * @param encoding Must be "buffer" to return a Buffer
	 * @param timestamp Unix timestamp in milliseconds, defaults to `Date.now()`
	 * @return Buffer The generated UUIDv7 as a Buffer
	 *
	 * @example
	 * ```haxe
	 * // Generate UUID as Buffer
	 * final uuidBuffer = Bun.randomUUIDv7(Buffer);
	 * trace(uuidBuffer.length); // 16 bytes
	 * 
	 * // Generate with custom timestamp
	 * final customTime = 1704067200000; // Unix timestamp
	 * final timestampedBuffer = Bun.randomUUIDv7(Buffer, customTime);
	 * ```
	**/
	public static overload function randomUUIDv7(encoding:UUIDv7BufferEncoding, ?timestamp:EitherType<Float, js.lib.Date>):Buffer;

	/**
	 * Synchronously spawns a subprocess. Receives an array of commands, and the first element will be resolved to an absolute executable path. It must be a file.
	 * @param commands 
	 * @return SyncSubprocess
	**/
	public static function spawnSync(commands:Array<String>, ?options:bun.processes.SpawnOptions):SyncChildProcess;

	/**
	 * Spawns a subprocess asynchronously. The first element of the commands array will be resolved
	 * to an absolute executable path. It must be a file.
	 * 
	 * Example:
	 * ```haxe
	 * // Using the simple API with command array
	 * final proc = Bun.spawn(["echo", "hello world"]);
	 * final output = await new js.html.Response(proc.stdout).text();
	 * trace(output); // "hello world"
	 * 
	 * // Using IPC to communicate between processes
	 * final child = Bun.spawn(["bun", "child.ts"], {
	 *   ipc: (message, childProc) -> {
	 *     trace('Message from child: $message');
	 *     childProc.send("Hello from parent");
	 *   }
	 * });
	 * 
	 * child.send("Start working"); // Send message to child
	 * ```
	 * 
	 * Child processes can communicate back using:
	 * ```haxe
	 * // In the child process
	 * process.send("Hello from child");
	 * 
	 * process.on("message", (message) -> {
	 *   trace('Message from parent: $message');
	 * });
	 * ```
	 * 
	 * @param commands Array of command and arguments to execute
	 * @param options Optional spawn configuration
	 * @return Subprocess An asynchronous subprocess object
	**/
	public static overload function spawn(commands:Array<String>, ?options:bun.processes.SpawnOptions):ChildProcess;

	/**
	 * Starts a HTTP(S) server.
	 * Original function from Bun.
	 * Haxe typedefs don't support the @:native metadata. Since the `ServeOptions` typedef may have a field called `static`,
	 * and that's a reserved word in Haxe, we wrap the original `serve` function to manually add it, if the user passes a `staticRoutes` field.
	 * @return Server
	**/
	@:native("serve") static function serveOriginal<T:Any>(options:ServeOptions<T>):BunHttpServer<T>;

	/**
	 * Starts a HTTP(S) server. 
	 * 
	 * This function's behavior is non-blocking, but the program will only close after all server instances are stopped.
	 * @param options An object describing how the server should operate. 
	 * It may include a `fetch` handler, which receives a `Request` returns a `Response` or a `Promise<Response>`.
	 * For better route handling, you can use the `routes` field to define static routes or method-specific handlers.
	 * @return Server
	**/
	overload public static inline function serve<T:Any>(options:ServeOptions<T>):BunHttpServer<T> {
		if (options.staticRoutes != null) {
			js.Syntax.code("options.static = options.staticRoutes;");
		}
		return serveOriginal(options);
	}

	/**
	 * Starts a HTTP(S) server. 
	 * 
	 * This function's behavior is non-blocking, but the program will only close after all server instances are stopped.
	 * @param options An object describing how the server should operate. 
	 * It must at least include a `fetch` handler, which receives a `Request` returns a `Response` or a `Promise<Response>`.
	 * This is a safe equivalent of `serve`. It wraps the return value of this function in a `Result` type and never throws.
	 * @return Result<Server, Any>
	**/
	public static inline function serveSafe<T:Any>(options:ServeOptions<T>):Result<BunHttpServer<T>, String> {
		try {
			if (options.staticRoutes != null) {
				js.Syntax.code("options.static = options.staticRoutes;");
			}
			final server = serve(options);
			return Ok(server);
		} catch (e) {
			return Error(e.message);
		}
	};

	/**
	 * Starts a HTTP server.
	 * 
	 * This function's behavior is non-blocking, but the program will only close after all server instances are stopped.
	 * @param fetch A function that receives a `Request` and returns either a `Response` or a `Promise<Response>`.
	 * @return Server
	**/
	overload public static inline function serve<T:Any>(fetch:(Request) -> EitherType<Response, Promise<Response>>):BunHttpServer {
		return serve({fetch: fetch});
	}

	/**
	 * Starts a HTTP server.
	 * 
	 * This function's behavior is non-blocking, but the program will only close after all server instances are stopped.
	 * @param fetch A function that receives a `Request` and returns either a `Promise` or a `Promise<Response>`.
	 * @param port The port this server will listen to.
	 * @return Server
	**/
	overload public static inline function serve<T:Any>(fetch:(Request) -> EitherType<Response, Promise<Response>>, port:Int):BunHttpServer {
		return serve({fetch: fetch, port: port});
	}

	/**
	 * Asyncronously writes data to a file. The data to write can be a `String`, an `ArrayBufferView` (such as an `Uint8Array` and other typed Arrays), 
	 * a `Response` instance, or a `BytesData` instance.
	 * This function doesn't enforce any type check at compile time - use the other write functions if possible. 
	 * @param file 
	 * @param data The data to write to the file.
	 * @return Promise<Int> Return a `Promise` with the number of bytes written to the file.
	**/
	@:native("write") public static overload function writeRaw(file:EitherType<String, BunFile>, data:Any):Promise<Int>;

	/**
	 * Asyncronously writes data to a file. The data to write can be a `String`, an `ArrayBufferView` (such as an `Uint8Array` and other typed Arrays), 
	 * a `Response` instance, or a `BytesData` instance.
	 * This function doesn't enforce any type check at compile time - use the other write functions if possible. 
	 * @param file 
	 * @param data The data to write to the file.
	 * @return Promise<Int> Return a `Promise` with the number of bytes written to the file.
	**/
	public static inline function write(file:EitherType<String, BunFile>, data:Any):ResultPromise<Int, FileSystemError> {
		return writeRaw(file, data).then(number -> Ok(number), error -> Result.Error(error));
	};

	/**
	 * Asyncronously writes data to a file.
	 * @param file 
	 * @param data The data to write to the file.
	 * @return Promise<Int> Return a `Promise` with the number of bytes written to the file.
	**/
	public static overload inline function writeString(file:EitherType<String, BunFile>, data:String):ResultPromise<Int, FileSystemError> {
		return write(file, data);
	}

	/**
	 * Asyncronously writes data to a file.
	 * @param file 
	 * @param data The data to write to the file.
	 * @return Promise<Int> Return a `Promise` with the number of bytes written to the file.
	**/
	public static overload inline function writeArrayBuffer(file:EitherType<String, BunFile>, data:ArrayBufferView):ResultPromise<Int, FileSystemError> {
		return write(file, data);
	}

	/**
	 * Asyncronously writes data to a file.
	 * @param file 
	 * @param data The data to write to the file.
	 * @return Promise<Int> Return a `Promise` with the number of bytes written to the file.
	**/
	public static overload inline function writeResponse(file:EitherType<String, BunFile>, data:Response):ResultPromise<Int, FileSystemError> {
		return write(file, data);
	}

	/**
	 * Asyncronously writes data to a file.
	 * @param file 
	 * @param data The data to write to the file.
	 * @return Promise<Int> Return a `Promise` with the number of bytes written to the file.
	**/
	public static overload inline function writeBytesData(file:EitherType<String, BunFile>, data:haxe.io.BytesData):ResultPromise<Int, FileSystemError> {
		return write(file, data);
	}

	/**
		Creates a bound UDP socket. If you don't specify a port number, one will be assigned
		by the Operating System.
	**/
	public static overload function udpSocket(udpSocketOptions:UdpSocketOptions):Promise<UdpSocket>;

	/**
		Creates a bound, connected UDP socket. If you don't specify a port number, one will be assigned
		by the Operating System.
		Every package will be sent to the specified address, and incoming packets are restricted to this
		specific peer only.
	**/
	public static overload function udpSocket(udpSocketOptions:ConnectedUdpSocketOptions):Promise<ConnectedUdpSocket>;
}

/**
 * Error object returned when Bun fails to write on the file system for some reason.
 * Those follow typical OS standards and can be looked up easily if you're debugging your program.
 * For example, trying to write to a file when you don't have permissions to on Linux will return
 * a `FileSystemError` with code "EACCESS".
 * `errno` is usually a negative number - this is for Node.js compatibility.
**/
typedef FileSystemError = {
	code:String,
	path:String,
	syscall:String,
	errno:Int
}

private typedef EditorOptions = {
	?editor:Editor,
	?line:String,
	?column:String
}

private typedef ZlibCompressionOptions = {
	/**
	 * The compression level to use. Must be between `-1` and `9`.
	 * - A value of `-1` uses the default compression level (Currently `6`)
	 * - A value of `0` gives no compression
	 * - A value of `1` gives least compression, fastest speed
	 * - A value of `9` gives best compression, slowest speed
	 */
	?level:Int,

	/**
	 * How much memory should be allocated for the internal compression state.
	 * A value of `1` uses minimum memory but is slow and reduces compression ratio.
	 * A value of `9` uses maximum memory for optimal speed. The default is `8`.
	 */
	?memLevel:Int,

	/**
	 * The base 2 logarithm of the window size (the size of the history buffer).
	 * Larger values of this parameter result in better compression at the expense of memory usage.
	 * The following value ranges are supported:
	 *  - `9..15`: The output will have a zlib header and footer (Deflate)
	 * - `-9..-15`: The output will **not** have a zlib header or footer (Raw Deflate)
	 * - `25..31`: The output will have a gzip header and footer (gzip)
	 * The gzip header will have no file name, no extra data, no comment, no modification time (set to zero) and no header CRC.
	 */
	?windowBits:Int
}

/**
 * List of code editors supported by Bun's `openInEditor` function.
**/
private enum abstract Editor(String) {
	final VSCode = "vscode";
	final SublimeText = "subl";
}

/**
 * `Bun.password` is a collection of utility functions for hashing and verifying passwords with various cryptographically secure algorithms.
**/
interface Password {
	/**
	 * Asynchronously hash a password using argon2 or bcrypt. The default is argon2.
	 * @param password If empty, this function throws an error. It is usually a programming mistake to hash an empty password.
	 * @return A promise that resolves to the hashed password
	**/
	function hash(password:String):Promise<String>;

	/**
	 * Hash a password using argon2 or bcrypt. The default is argon2.
	 * @param password If empty, this function throws an error. It is usually a programming mistake to hash an empty password.
	 * @return The hashed password
	**/
	function hashSync(password:String):String;

	/**
	 * Asynchronously verify a password against a previously hashed password.
	 * @param plaintextPassword The plain text password as a String.
	 * @param hashedPassword The hash String created by the `hash` or `hashSync` functions
	 * @return Promise<Bool>
	**/
	function verify(plaintextPassword:String, hashedPassword:String):Promise<Bool>;

	/**
	 * Verify a password against a previously hashed password.
	 * @param plaintextPassword The plain text password as a String.
	 * @param hashedPassword The hash String created by the `hash` or `hashSync` functions
	 * @return Bool
	**/
	function verifySync(plaintextPassword:String, hashedPassword:String):Bool;
}

/**
 * A static response that can be returned directly without processing.
 * This is the most efficient option as no function calls are needed.
 *
 * @example
 * ```haxe
 * final staticResponse = new Response("Hello World");
 * ```
**/
typedef StaticRouteResponse = Response;

/**
 * A simple route handler function that takes no parameters and returns a response.
 * Useful for routes that don't need access to the request object.
 *
 * @example
 * ```haxe
 * final simpleHandler = () -> new Response("Hello World");
 * final asyncHandler = () -> Promise.resolve(new Response("Hello Async"));
 * ```
**/
typedef SimpleRouteFunction = () -> EitherType<Response, Promise<Response>>;

/**
 * A route handler function that optionally receives the request object.
 * The request parameter is optional, making this flexible for handlers that may or may not need it.
 *
 * @example
 * ```haxe
 * final optionalReqHandler = (?req:Request) -> {
 *   if (req != null) {
 *     final url = req.url;
 *     return new Response('Request to: $url');
 *   }
 *   return new Response("No request provided");
 * };
 * ```
**/
typedef OptionalRequestRouteFunction = (?req:Request) -> EitherType<Response, Promise<Response>>;

/**
 * A route handler function that requires the request object and returns a Promise.
 * This is the most common pattern for async route handlers that need request data.
 *
 * @example
 * ```haxe
 * final asyncReqHandler = (req:Request) -> {
 *   return req.json().then(data -> {
 *     return new Response('Received: ${haxe.Json.stringify(data)}');
 *   });
 * };
 * ```
**/
typedef AsyncRequestRouteFunction = (req:Request) -> Promise<Response>;

/**
 * A flexible route handler that can be any of the supported response types.
 * This allows for maximum flexibility in how routes are defined.
 *
 * @example
 * ```haxe
 * // Using different handler types
 * final routes = [
 *   "/static" => new Response("Static response"),
 *   "/simple" => () -> new Response("Simple function"),
 *   "/with-request" => (req:Request) -> new Response('Path: ${req.url}'),
 *   "/async" => (req:Request) -> Promise.resolve(new Response("Async response"))
 * ];
 * ```
**/
typedef RouteHandler = EitherOf4<StaticRouteResponse, SimpleRouteFunction, OptionalRequestRouteFunction, AsyncRequestRouteFunction>;

/**
 * HTTP method-specific route handlers for a single route path.
 * Each HTTP method can have its own handler, allowing for RESTful API design.
 *
 * @example
 * ```haxe
 * final userRoutes:RouteMethodHandler = {
 *   GET: (req:Request) -> {
 *     // Handle GET /users - list users
 *     return Promise.resolve(new Response('{"users": []}'));
 *   },
 *   POST: (req:Request) -> {
 *     // Handle POST /users - create user
 *     return req.json().then(userData -> {
 *       // Process user creation
 *       return new Response('{"created": true}', {status: 201});
 *     });
 *   },
 *   PUT: (req:Request) -> {
 *     // Handle PUT /users - update user
 *     return new Response('{"updated": true}');
 *   },
 *   DELETE: (req:Request) -> {
 *     // Handle DELETE /users - delete user
 *     return new Response('{"deleted": true}');
 *   }
 * };
 *
 * // Usage in server configuration
 * final server = Bun.serve({
 *   routes: {
 *     "/users": userRoutes,
 *     "/health": {
 *       GET: new Response("OK"),
 *       HEAD: new Response("", {status: 200})
 *     }
 *   },
 *   fetch: (req) -> new Response("Not Found", {status: 404})
 * });
 * ```
**/
typedef RouteMethodHandler = {
	/**
	 * Handler for GET requests - typically used for retrieving data.
	**/
	var ?GET:RouteHandler;

	/**
	 * Handler for POST requests - typically used for creating new resources.
	**/
	var ?POST:RouteHandler;

	/**
	 * Handler for PUT requests - typically used for updating existing resources.
	**/
	var ?PUT:RouteHandler;

	/**
	 * Handler for DELETE requests - typically used for removing resources.
	**/
	var ?DELETE:RouteHandler;

	/**
	 * Handler for PATCH requests - typically used for partial updates.
	**/
	var ?PATCH:RouteHandler;

	/**
	 * Handler for OPTIONS requests - typically used for CORS preflight requests.
	**/
	var ?OPTIONS:RouteHandler;

	/**
	 * Handler for HEAD requests - typically used for checking resource existence without body.
	**/
	var ?HEAD:RouteHandler;
}

/**
 * An object containing configuration for a Bun HTTP(S) server.
**/
typedef ServeOptions<T> = {
	/**
	 * The `fetch` function receives a `Request` and it must return a `Response`, which is forwarded to the client.
	 **/
	var ?fetch:EitherType<(Request) -> Null<EitherType<Response, Promise<Response>>>,
		(Request, BunHttpServer<T>) -> Null<EitherType<Response, Promise<Response>>>>;

	/**
	 * The hostname which the server will listen on. Defaults to "0.0.0.0".
	 **/
	var ?hostname:String;

	/**
	 * The port which the server will listen on. Defaults to 3000.
	 **/
	var ?port:Int;

	/**
	 * Controls whether the development mode is enabled or not. By default, development mode is __enabled__, unless the `NODE_ENV` enviroment variable is set to `production`.
	 * In development mode, Bun will surface errors in-browser with a built-in error page.
	 **/
	var ?development:Bool;

	/**
	 * Optional handler function to send a custom response to clients when a server-side error happens.
	 **/
	var ?error:(Error) -> EitherType<Response, Promise<Response>>;

	/**
	 * You can enable TLS by passing in a value for key and cert; both are required to enable TLS.
	 * The key and cert fields expect __the contents__ of your TLS key and certificate, _not a path to it_.
	 **/
	var ?tls:{?key:String, ?cert:String};

	var ?ca:String;
	var ?passphrase:String;
	var ?dhParamsFile:String;
	var ?lowMemoryMode:Bool;

	var ?websocket:WebSocketHandler<T>;

	/**
	 * By default, Bun will close a WebSocket connection if it is idle for 120 seconds. 
	 * This can be configured with the idleTimeout property. Value is in seconds.
	 **/
	var ?idleTimeout:Int;

	/**
	 * Bun will close a connection if it receives a message larger than 16MB.
	 * You can configure a custom value through this property. Value is in bytes.
	 **/
	var ?maxPayloadLength:Int;

	/**
	 * The optional static field can hold static `Response` objects for defined routes. This is faster than
	 * using the fetch router, as new `Response` objects don't have to be created for each request.
	 **/
	@:native("static") var ?staticRoutes:Dynamic<Response>;

	/**
	 * The optional routes field provides a declarative way to define route handlers.
	 * This is often faster than using the fetch router, as responses can be pre-computed
	 * and routes are matched more efficiently.
	 *
	 * Routes can be defined as:
	 * - Direct `RouteHandler` for simple path-to-handler mapping
	 * - `RouteMethodHandler` for HTTP method-specific handlers on the same path
	 *
	 * @example
	 * ```haxe
	 * final server = Bun.serve({
	 *   routes: {
	 *     // Simple route handlers
	 *     "/": new Response("Welcome!"),
	 *     "/ping": () -> new Response("pong"),
	 *     "/echo": (req:Request) -> new Response(req.url),
	 *     
	 *     // Method-specific handlers
	 *     "/api/users": {
	 *       GET: (req:Request) -> Promise.resolve(new Response('{"users": []}')),
	 *       POST: (req:Request) -> req.json().then(data -> 
	 *         new Response('{"created": true}', {status: 201}))
	 *     },
	 *     
	 *     // Mixed approach
	 *     "/health": {
	 *       GET: new Response("OK"),
	 *       HEAD: new Response("", {status: 200})
	 *     }
	 *   },
	 *   fetch: (req) -> new Response("Not Found", {status: 404})
	 * });
	 * ```
	**/
	@:native("routes") var ?routes:Dynamic<EitherType<RouteHandler, RouteMethodHandler>>;
}

/**
 * A instance of a HTTP/WebSocket server started by Bun.
**/
interface BunHttpServer<T = Any> {
	/**
	 * Whether the server was started in development mode or not.
	**/
	var development(default, never):Bool;

	var hostname(default, never):String;

	/**
	 * The port this server is running on.
	**/
	var port(default, never):Int;

	var pendingRequests(default, never):Int;

	/**
	 * Makes the server stop listening to connections.
	**/
	function stop():Void;

	/**
	 * Tries to upgrade the Request into a WebSocket. Returns `true` if it succeeds, and false otherwise.
	 * @param req the `Request` to upgrade.
	 * @return Bool
	**/
	function upgrade(req:Request, ?data:{data:T}):Bool;

	/**
	 * Broadcasts a message to every connection listening to this topic.
	 * The message can be a `String` or a `BytesData` instance.
	 * @param topic the topic you want to broadcast to.
	 * @param content the content/message you're broadcasting.
	 * @return Int an integer that indicates whether the broadcast was successful or not. Values bigger than 0
	 * indicate that the message was sent successfully.
	**/
	function publish(topic:String, content:EitherType<String, EitherType<BytesData, js.lib.ArrayBufferView>>):Int;
}

/**
 * A structure containing functions that handle WebSocket events.
**/
typedef WebSocketHandler<T> = {
	?message:(ws:bun.ServerWebSocket<T>, message:EitherType<String, BytesData>) -> Void,
	?open:(ws:bun.ServerWebSocket<T>) -> Void,
	?close:(ws:bun.ServerWebSocket<T>, code:Int, reason:String) -> Void,
	?drain:(ws:bun.ServerWebSocket<T>) -> Void,
	?idleTimeout:Int,
}

/**
 * Sends a HTTP request to an URL.
 * @param url the URL you're making a request to, as a String
 * @param init? optional parameters to configure this request.
 * @return Promise<Response>
**/
@:native("fetch") extern function fetchRaw(url:String, ?init:js.html.RequestInit):Promise<Response>;

/**
 * Sends a HTTP request to an URL.
 * @param url the URL you're making a request to, as a String
 * @param init? optional parameters to configure this request.
 * Wrapper around `fetchRaw` that never rejects, and instead returns a Promise of an `Option` type.
 * @return ResultPromise<Response, FetchError>
**/
@:native("fetchSafe") function fetch(url:String, ?init:js.html.RequestInit):ResultPromise<Response, FetchError> {
	return fetchRaw(url, init).then(v -> Ok(v), err -> Result.Error(FailedToConnect(err)));
};

/**
 * Sends a HTTP request to an URL, parses the JSON response and returns an object typed as `Any`.
 * @param url the URL you're making a request to, as a String
 * @param init? optional parameters to configure this request.
 * Wrapper around `fetchRaw` that never rejects, and instead returns a Promise of a `Result` type.
 * @return ResultPromise<Any, FetchError>
**/
function fetchJson(url:String, ?init:js.html.RequestInit):ResultPromise<Any, FetchError> {
	function parseRawResponse(rawResponse:Response) {
		return rawResponse.json().then(obj -> Ok(obj), err -> Result.Error(JsonParseError(err)));
	}
	return fetchRaw(url, init).then(parseRawResponse, err -> Result.Error(FailedToConnect(err)));
};

/**
 * Possible errors returned by `fetch` functions.
**/
enum FetchError {
	FailedToConnect(nativeErrorMessage:String);
	JsonParseError(nativeErrorMessage:String);
}

/**
 * Provides a simple interface to read and set environment variables.
**/
abstract Environment(Dynamic) {
	@:op(a.b) public function get(name:String):Null<String>
		return Syntax.code("process.env[{0}]", name);

	@:op(a.b) public function set(name:String, value:String):Void
		Syntax.code("process.env[{0}] = {1}", name, value);
}

/**
 * Encoding options for UUIDv7 string generation.
**/
enum abstract UUIDv7Encoding(String) to String {
	/** Hexadecimal encoding (default) - returns format like "0192ce07-8c4f-7d66-afec-2482b5c9b03c" **/
	final Hex = "hex";

	/** Base64 encoding **/
	final Base64 = "base64";

	/** Base64 URL-safe encoding **/
	final Base64Url = "base64url";
}

/**
 * Encoding option for UUIDv7 Buffer generation.
**/
enum abstract UUIDv7BufferEncoding(String) to String {
	/** Buffer encoding - returns a Buffer object **/
	final Buffer = "buffer";
}
