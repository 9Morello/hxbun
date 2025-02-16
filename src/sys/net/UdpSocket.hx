package sys.net;

import helpers.EitherOf.EitherOf3;
import helpers.EitherOf.EitherOf4;
import js.node.Buffer;
import haxe.extern.EitherType;
import js.node.net.Socket.SocketAdressFamily;
import js.node.net.Socket.SocketAdress;
import js.lib.Promise;
import js.node.net.Socket;
import js.html.BinaryType;
import js.lib.ArrayBufferView;
import js.lib.ArrayBuffer;
import haxe.io.BytesData;

typedef Data = EitherOf4<ArrayBuffer, BytesData, String, Buffer>;

private extern class UdpSocketBase {
	private function new();

	public final hostname:String;
	public final port:Int;
	public final address:SocketAdress;
	public final binaryType:BinaryType;
	public var closed(default, never):Bool;

	public function close():Void;
}

/**
	UDP Socket instantiated by `Bun.udpSocket`.
	Send data to a specific address + port' using the `send` function.
	Note that the `address` parameter must be a valid IP address. That function
	does not perform DNS resolution.
**/
extern class UdpSocket extends UdpSocketBase {
	private function new();

	public function sendMany(packets:Array<Any>):Int;

	/**
		Sends data to a specified address and port. The address must be a valid IP address.
		This function won't trigger any kind of DNS resolution.
	**/
	public function send(data:Data, port:Int, address:String):Bool;

	public function reload(handler:UdpSocketOptions):Void;
}

/**
	UDP Socket instantiated by `Bun.udpSocket`, associated with a specific peer
	  (address + Port).
	Note that the `address` parameter must be a valid IP address. That function
	does not perform DNS resolution.
**/
extern class ConnectedUdpSocket extends UdpSocketBase {
	private function new();

	public function sendMany(packets:Array<Data>):Int;

	/**
		Sends data to the connected peer. Returns `true` if it succeeded, and `false` otherwise.
	**/
	public function send(data:Data):Bool;

	public function reload(handler:ConnectedUdpSocketOptions):Void;
}

/**
	Options for creating a UDP socket.
	If you do not specify a port, your OS will assign one for you.
	Pass a handler on the `socket` property to handle incoming messages on your UDP socket.
**/
typedef UdpSocketOptions = {
	?port:Int,
	?hostname:String,
	?binaryType:BinaryType,
	?socket:UdpSocketHandler,
	?connect:Null<Void>,
}

typedef ConnectedUdpSocketOptions = {
	?port:Int,
	?hostname:String,
	?binaryType:BinaryType,
	?socket:UdpSocketHandler,
	connect:{
		port:Int, hostname:String,
	}
}

typedef UdpSocketHandler = {
	?data:EitherType<(socket:UdpSocket, data:Data, port:Int, address:String,) -> Void,
		(socket:UdpSocket, data:Data, port:Int, address:String,) -> Promise<Void>>,
	?drain:(socket:UdpSocket) -> EitherType<Void, Promise<Void>>,
	?error:(socket:UdpSocket, error:js.lib.Error) -> EitherType<Void, Promise<Void>>,
}
