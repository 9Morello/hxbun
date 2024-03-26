package bun;

import haxe.extern.EitherType;
import js.html.Blob;
import js.html.URL;
import js.lib.ArrayBuffer;
import js.lib.ArrayBufferView;

/**
	An enum representing the current state of the WebSocket.
**/
enum abstract ReadyState(Int) from Int {
	final CONNECTING;
	final OPEN;
	final CLOSING;
	final CLOSED;
}

/**
 * A server-side WebSocket created by an incoming connection from a client.
**/
extern class ServerWebSocket<T> {
	/**
		The current state of the websocket.
	**/
	public var readyState(default, never):ReadyState;

	private function new();

	/**
	 * Sends data to the connected WebSocket.
	 * @param data The data to be sent. Can be either a `String`, an `ArrayBuffer`, a `Blob` or a `TypedArray`.
	 * Returns the amount of bytes sent. If you send data and this functions returns `0`, the WebSocket
	 * is likely closed. 
	**/
	overload public function send(data:EitherType<EitherType<String, ArrayBuffer>, EitherType<Blob, ArrayBufferView>>):Int;

	/**
	 * Sends data to the connected WebSocket.
	 * @param bytes The data to be sent (as `Bytes`).
	**/
	public inline function sendBytes(bytes:haxe.io.Bytes):Int {
		return send(bytes.getData());
	};

	/**
	 * Sends data to the connected WebSocket.
	 * @param bytes The data to be sent (as `String`).
	**/
	public inline function sendString(data:String):Int {
		return send(data);
	};

	public var data(default, never):T;

	/**
	 * Subscribes this WebSocket to a topic.
	 * When you call `publish` on your server, you specify a "topic" (`String`), and
	 * the message's content. Every connected WebSocket that is subscribed to that topic 
	 * will receive the published message. 
	 * @param topic The topic you're subscribing to.
	**/
	public function subscribe(topic:String):Void;

	/**
	 * Removes a subscription from this WebSocket.
	 * After you call this function, this WebSocket won't receive messages with this
	 * topic, unless you subscribe to it again.
	 * @param topic The topic you're subscribing to.
	 */
	public function unsubscribe(topic:String):Void;
}
