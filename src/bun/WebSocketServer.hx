package bun;

import js.lib.ArrayBufferView;
import js.html.Blob;
import js.lib.ArrayBuffer;
import js.html.URL;
import haxe.extern.EitherType;

/**
 * A client that makes an outgoing WebSocket connection.
 */
extern class WebSocketServer<T> {
	private function new();

	/**
	 * Sends data to the connected WebSocket.
	 * @param data The data to be sent. Can be either a `String`, an `ArrayBuffer`, a `Blob` or a `TypedArray`.
	 */
	overload public function send(data:EitherType<EitherType<String, ArrayBuffer>, EitherType<Blob, ArrayBufferView>>):Void;

	/**
	 * Sends data to the connected WebSocket.
	 * @param bytes The data to be sent (as `Bytes`).
	 */
	public inline function sendBytes(bytes:haxe.io.Bytes):Void {
		send(bytes.getData());
	};

	/**
	 * Sends data to the connected WebSocket.
	 * @param bytes The data to be sent (as `String`).
	 */
	public inline function sendString(data:String):Void {
		send(data);
	};

	public var data(default, never):T;

	/**
	 * Subscribes this WebSocket to a topic.
	 * When you call `publish` on your server, you specify a "topic" (`String`), and
	 * the message's content. Every connected WebSocket that is subscribed to that topic 
	 * will receive the published message. 
	 * @param topic The topic you're subscribing to.
	 */
	public function subscribe(topic:String):Void;

	/**
	 * Removes a subscription from this WebSocket.
	 * After you call this function, this WebSocket won't receive messages with this
	 * topic, unless you subscribe to it again.
	 * @param topic The topic you're subscribing to.
	 */
	public function unsubscribe(topic:String):Void;
}
