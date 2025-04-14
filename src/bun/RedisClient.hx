package bun;

import haxe.io.Bytes;
import haxe.io.BytesData;
import js.lib.Promise;
import js.lib.Error;
import js.html.Blob;
import js.lib.ArrayBufferView;
import haxe.extern.EitherType;
import haxe.DynamicAccess;
import helpers.EitherOf.EitherOf3;

/**
 * Options for configuring a Redis client connection
 */
typedef RedisOptions = {
	/**
	 * URL to connect to, defaults to "redis://localhost:6379"
	 * Supported protocols: redis://, rediss://, redis+unix://, redis+tls://
	 */
	?url:String,

	/**
	 * Connection timeout in milliseconds
	 * @default 10000
	 */
	?connectionTimeout:Int,

	/**
	 * Idle timeout in milliseconds
	 * @default 0 (no timeout)
	 */
	?idleTimeout:Int,

	/**
	 * Whether to automatically reconnect
	 * @default true
	 */
	?autoReconnect:Bool,

	/**
	 * Maximum number of reconnection attempts
	 * @default 10
	 */
	?maxRetries:Int,

	/**
	 * Whether to queue commands when disconnected
	 * @default true
	 */
	?enableOfflineQueue:Bool,

	/**
	 * TLS options
	 * Can be a boolean or an object with TLS options
	 */
	?tls:EitherType<Bool, {
		?key:EitherType<String, BytesData>,
		?cert:EitherType<String, BytesData>,
		?ca:EitherOf3<String, BytesData, Array<EitherType<String, BytesData>>>,
		?rejectUnauthorized:Bool
	}>,

	/**
	 * Whether to enable auto-pipelining
	 * @default true
	 */
	?enableAutoPipelining:Bool
}

/**
 * A Redis key can be a string, an ArrayBufferView, or a Blob.
 */
typedef RedisKey = EitherOf3<String, ArrayBufferView, Blob>;

private extern interface RedisClientInterface {
	/**
	 * Whether the client is connected to the Redis server
	 */
	var connected(default, null):Bool;

	/**
	 * Amount of data buffered in bytes
	 */
	var bufferedAmount(default, null):Int;

	/**
	 * Callback fired when the client connects to the Redis server
	 */
	var onconnect:Void->Void;

	/**
	 * Callback fired when the client disconnects from the Redis server
	 * @param error The error that caused the disconnection
	 */
	var onclose:Error->Void;

	/**
	 * Connect to the Redis server
	 * @returns A promise that resolves when connected
	 */
	function connect():Promise<Void>;

	/**
	 * Disconnect from the Redis server
	 */
	function close():Void;

	/**
	 * Send a raw command to the Redis server
	 * @param command The command to send
	 * @param args The arguments to the command
	 * @returns A promise that resolves with the command result
	 */
	function send(command:String, args:Array<String>):Promise<Dynamic>;

	/**
	 * Get the value of a key
	 * @param key The key to get
	 * @returns Promise that resolves with the key's value, or null if the key doesn't exist
	 */
	function get(key:RedisKey):Promise<Null<String>>;

	/**
	 * Set key to hold the string value
	 * @param key The key to set
	 * @param value The value to set
	 * @returns Promise that resolves with "OK" on success
	 */
	@:overload(function(key:RedisKey, value:RedisKey):Promise<String> {})
	@:overload(function(key:RedisKey, value:RedisKey, ex:String, seconds:Int):Promise<String> {})
	@:overload(function(key:RedisKey, value:RedisKey, px:String, milliseconds:Int):Promise<String> {})
	@:overload(function(key:RedisKey, value:RedisKey, exat:String, timestampSeconds:Int):Promise<String> {})
	@:overload(function(key:RedisKey, value:RedisKey, pxat:String, timestampMilliseconds:Int):Promise<String> {})
	@:overload(function(key:RedisKey, value:RedisKey, nx:String):Promise<Null<String>> {})
	@:overload(function(key:RedisKey, value:RedisKey, xx:String):Promise<Null<String>> {})
	@:overload(function(key:RedisKey, value:RedisKey, get:String):Promise<Null<String>> {})
	@:overload(function(key:RedisKey, value:RedisKey, keepttl:String):Promise<String> {})
	function set(key:RedisKey, value:RedisKey, ...options:String):Promise<EitherType<String, Null<String>>>;

	/**
	 * Delete a key
	 * @param key The key to delete
	 * @returns Promise that resolves with the number of keys removed
	 */
	function del(key:RedisKey):Promise<Int>;

	/**
	 * Increment the integer value of a key by one
	 * @param key The key to increment
	 * @returns Promise that resolves with the new value
	 */
	function incr(key:RedisKey):Promise<Int>;

	/**
	 * Decrement the integer value of a key by one
	 * @param key The key to decrement
	 * @returns Promise that resolves with the new value
	 */
	function decr(key:RedisKey):Promise<Int>;

	/**
	 * Determine if a key exists
	 * @param key The key to check
	 * @returns Promise that resolves with true if the key exists, false otherwise
	 */
	function exists(key:RedisKey):Promise<Bool>;

	/**
	 * Set a key's time to live in seconds
	 * @param key The key to set the expiration for
	 * @param seconds The number of seconds until expiration
	 * @returns Promise that resolves with 1 if the timeout was set, 0 if not
	 */
	function expire(key:RedisKey, seconds:Int):Promise<Int>;

	/**
	 * Get the time to live for a key in seconds
	 * @param key The key to get the TTL for
	 * @returns Promise that resolves with the TTL, -1 if no expiry, or -2 if key doesn't exist
	 */
	function ttl(key:RedisKey):Promise<Int>;

	/**
	 * Set multiple hash fields to multiple values
	 * @param key The hash key
	 * @param fieldValues An array of alternating field names and values
	 * @returns Promise that resolves with "OK" on success
	 */
	function hmset(key:RedisKey, fieldValues:Array<String>):Promise<String>;

	/**
	 * Get the values of all the given hash fields
	 * @param key The hash key
	 * @param fields The fields to get
	 * @returns Promise that resolves with an array of values
	 */
	function hmget(key:RedisKey, fields:Array<String>):Promise<Array<Null<String>>>;

	/**
	 * Check if a value is a member of a set
	 * @param key The set key
	 * @param member The member to check
	 * @returns Promise that resolves with true if the member exists, false otherwise
	 */
	function sismember(key:RedisKey, member:String):Promise<Bool>;

	/**
	 * Add a member to a set
	 * @param key The set key
	 * @param member The member to add
	 * @returns Promise that resolves with 1 if the member was added, 0 if it already existed
	 */
	function sadd(key:RedisKey, member:String):Promise<Int>;

	/**
	 * Remove a member from a set
	 * @param key The set key
	 * @param member The member to remove
	 * @returns Promise that resolves with 1 if the member was removed, 0 if it didn't exist
	 */
	function srem(key:RedisKey, member:String):Promise<Int>;

	/**
	 * Get all the members in a set
	 * @param key The set key
	 * @returns Promise that resolves with an array of all members
	 */
	function smembers(key:RedisKey):Promise<Array<String>>;

	/**
	 * Get a random member from a set
	 * @param key The set key
	 * @returns Promise that resolves with a random member, or null if the set is empty
	 */
	function srandmember(key:RedisKey):Promise<Null<String>>;

	/**
	 * Remove and return a random member from a set
	 * @param key The set key
	 * @returns Promise that resolves with the removed member, or null if the set is empty
	 */
	function spop(key:RedisKey):Promise<Null<String>>;

	/**
	 * Increment the integer value of a hash field by the given number
	 * @param key The hash key
	 * @param field The field to increment
	 * @param increment The amount to increment by
	 * @returns Promise that resolves with the new value
	 */
	function hincrby(key:RedisKey, field:String, increment:EitherType<String, Int>):Promise<Int>;

	/**
	 * Increment the float value of a hash field by the given amount
	 * @param key The hash key
	 * @param field The field to increment
	 * @param increment The amount to increment by
	 * @returns Promise that resolves with the new value as a string
	 */
	function hincrbyfloat(key:RedisKey, field:String, increment:EitherType<String, Float>):Promise<String>;

	/**
	 * Get all the fields and values in a hash
	 * @param key The hash key
	 * @returns Promise that resolves with an object containing all fields and values
	 */
	function hgetall(key:RedisKey):Promise<Null<DynamicAccess<String>>>;

	/**
	 * Get all field names in a hash
	 * @param key The hash key
	 * @returns Promise that resolves with an array of field names
	 */
	function hkeys(key:RedisKey):Promise<Array<String>>;

	/**
	 * Get the number of fields in a hash
	 * @param key The hash key
	 * @returns Promise that resolves with the number of fields
	 */
	function hlen(key:RedisKey):Promise<Int>;

	/**
	 * Get all values in a hash
	 * @param key The hash key
	 * @returns Promise that resolves with an array of values
	 */
	function hvals(key:RedisKey):Promise<Array<String>>;

	/**
	 * Find all keys matching the given pattern
	 * @param pattern The pattern to match
	 * @returns Promise that resolves with an array of matching keys
	 */
	function keys(pattern:String):Promise<Array<String>>;

	/**
	 * Get the length of a list
	 * @param key The list key
	 * @returns Promise that resolves with the length of the list
	 */
	function llen(key:RedisKey):Promise<Int>;

	/**
	 * Remove and get the first element in a list
	 * @param key The list key
	 * @returns Promise that resolves with the first element, or null if the list is empty
	 */
	function lpop(key:RedisKey):Promise<Null<String>>;

	/**
	 * Remove the expiration from a key
	 * @param key The key to persist
	 * @returns Promise that resolves with 1 if the timeout was removed, 0 if the key doesn't exist or has no timeout
	 */
	function persist(key:RedisKey):Promise<Int>;

	/**
	 * Get the expiration time of a key as a UNIX timestamp in milliseconds
	 * @param key The key to check
	 * @returns Promise that resolves with the timestamp, or -1 if the key has no expiration, or -2 if the key doesn't exist
	 */
	function pexpiretime(key:RedisKey):Promise<Int>;

	/**
	 * Get the time to live for a key in milliseconds
	 * @param key The key to check
	 * @returns Promise that resolves with the TTL in milliseconds, or -1 if the key has no expiration, or -2 if the key doesn't exist
	 */
	function pttl(key:RedisKey):Promise<Int>;

	/**
	 * Remove and get the last element in a list
	 * @param key The list key
	 * @returns Promise that resolves with the last element, or null if the list is empty
	 */
	function rpop(key:RedisKey):Promise<Null<String>>;

	/**
	 * Get the number of members in a set
	 * @param key The set key
	 * @returns Promise that resolves with the cardinality (number of elements) of the set
	 */
	function scard(key:RedisKey):Promise<Int>;

	/**
	 * Get the length of the value stored in a key
	 * @param key The key to check
	 * @returns Promise that resolves with the length of the string value, or 0 if the key doesn't exist
	 */
	function strlen(key:RedisKey):Promise<Int>;

	/**
	 * Get the number of members in a sorted set
	 * @param key The sorted set key
	 * @returns Promise that resolves with the cardinality (number of elements) of the sorted set
	 */
	function zcard(key:RedisKey):Promise<Int>;

	/**
	 * Remove and return members with the highest scores in a sorted set
	 * @param key The sorted set key
	 * @returns Promise that resolves with the removed member and its score, or null if the set is empty
	 */
	function zpopmax(key:RedisKey):Promise<Null<String>>;

	/**
	 * Remove and return members with the lowest scores in a sorted set
	 * @param key The sorted set key
	 * @returns Promise that resolves with the removed member and its score, or null if the set is empty
	 */
	function zpopmin(key:RedisKey):Promise<Null<String>>;

	/**
	 * Get one or multiple random members from a sorted set
	 * @param key The sorted set key
	 * @returns Promise that resolves with a random member, or null if the set is empty
	 */
	function zrandmember(key:RedisKey):Promise<Null<String>>;

	/**
	 * Append a value to a key
	 * @param key The key to append to
	 * @param value The value to append
	 * @returns Promise that resolves with the length of the string after the append operation
	 */
	function append(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Set the value of a key and return its old value
	 * @param key The key to set
	 * @param value The value to set
	 * @returns Promise that resolves with the old value, or null if the key didn't exist
	 */
	function getset(key:RedisKey, value:RedisKey):Promise<Null<String>>;

	/**
	 * Prepend one or multiple values to a list
	 * @param key The list key
	 * @param value The value to prepend
	 * @returns Promise that resolves with the length of the list after the push operation
	 */
	function lpush(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Prepend a value to a list, only if the list exists
	 * @param key The list key
	 * @param value The value to prepend
	 * @returns Promise that resolves with the length of the list after the push operation, or 0 if the list doesn't exist
	 */
	function lpushx(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Add one or more members to a HyperLogLog
	 * @param key The HyperLogLog key
	 * @param element The element to add
	 * @returns Promise that resolves with 1 if the HyperLogLog was altered, 0 otherwise
	 */
	function pfadd(key:RedisKey, element:String):Promise<Int>;

	/**
	 * Append one or multiple values to a list
	 * @param key The list key
	 * @param value The value to append
	 * @returns Promise that resolves with the length of the list after the push operation
	 */
	function rpush(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Append a value to a list, only if the list exists
	 * @param key The list key
	 * @param value The value to append
	 * @returns Promise that resolves with the length of the list after the push operation, or 0 if the list doesn't exist
	 */
	function rpushx(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Set the value of a key, only if the key does not exist
	 * @param key The key to set
	 * @param value The value to set
	 * @returns Promise that resolves with 1 if the key was set, 0 if the key was not set
	 */
	function setnx(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Get the score associated with the given member in a sorted set
	 * @param key The sorted set key
	 * @param member The member to get the score for
	 * @returns Promise that resolves with the score of the member as a string, or null if the member or key doesn't exist
	 */
	function zscore(key:RedisKey, member:String):Promise<Null<String>>;

	/**
	 * Get the values of all specified keys
	 * @param keys The keys to get
	 * @returns Promise that resolves with an array of values, with null for keys that don't exist
	 */
	function mget(...keys:RedisKey):Promise<Array<Null<String>>>;

	/**
	 * Count the number of set bits (population counting) in a string
	 * @param key The key to count bits in
	 * @returns Promise that resolves with the number of bits set to 1
	 */
	function bitcount(key:RedisKey):Promise<Int>;

	/**
	 * Return a serialized version of the value stored at the specified key
	 * @param key The key to dump
	 * @returns Promise that resolves with the serialized value, or null if the key doesn't exist
	 */
	function dump(key:RedisKey):Promise<Null<String>>;

	/**
	 * Get the expiration time of a key as a UNIX timestamp in seconds
	 * @param key The key to check
	 * @returns Promise that resolves with the timestamp, or -1 if the key has no expiration, or -2 if the key doesn't exist
	 */
	function expiretime(key:RedisKey):Promise<Int>;

	/**
	 * Get the value of a key and delete the key
	 * @param key The key to get and delete
	 * @returns Promise that resolves with the value of the key, or null if the key doesn't exist
	 */
	function getdel(key:RedisKey):Promise<Null<String>>;

	/**
	 * Get the value of a key and optionally set its expiration
	 * @param key The key to get
	 * @returns Promise that resolves with the value of the key, or null if the key doesn't exist
	 */
	function getex(key:RedisKey):Promise<Null<String>>;
}

/**
 * Bun Redis client for interacting with Redis servers.
 * Provides methods for common Redis operations with a Promise-based API.
 */
@:js.customImport("bun", "RedisClient")
extern class RedisClient {
	/**
	 * Creates a new Redis client
	 * @param url URL to connect to, defaults to process.env.VALKEY_URL, process.env.REDIS_URL, or "valkey://localhost:6379"
	 * @param options Additional options
	 *
	 * Example:
	 * ```haxe
	 * var redis = new RedisClient();
	 * redis.set("hello", "world");
	 * redis.get("hello").then(value -> trace(value)); // Prints "world"
	 * ```
	 */
	@:overload(function(?url:String, ?options:RedisOptions):Void {})
	function new();

	/**
	 * Whether the client is connected to the Redis server
	 */
	var connected(default, null):Bool;

	/**
	 * Amount of data buffered in bytes
	 */
	var bufferedAmount(default, null):Int;

	/**
	 * Callback fired when the client connects to the Redis server
	 */
	var onconnect:Void->Void;

	/**
	 * Callback fired when the client disconnects from the Redis server
	 * @param error The error that caused the disconnection
	 */
	var onclose:Error->Void;

	/**
	 * Connect to the Redis server
	 * @returns A promise that resolves when connected
	 */
	function connect():Promise<Void>;

	/**
	 * Disconnect from the Redis server
	 */
	function close():Void;

	/**
	 * Send a raw command to the Redis server
	 * @param command The command to send
	 * @param args The arguments to the command
	 * @returns A promise that resolves with the command result
	 */
	function send(command:String, args:Array<String>):Promise<Dynamic>;

	/**
	 * Get the value of a key
	 * @param key The key to get
	 * @returns Promise that resolves with the key's value, or null if the key doesn't exist
	 */
	function get(key:RedisKey):Promise<Null<String>>;

	/**
	 * Set key to hold the string value
	 * @param key The key to set
	 * @param value The value to set
	 * @returns Promise that resolves with "OK" on success
	 */
	@:overload(function(key:RedisKey, value:RedisKey):Promise<String> {})
	@:overload(function(key:RedisKey, value:RedisKey, ex:String, seconds:Int):Promise<String> {})
	@:overload(function(key:RedisKey, value:RedisKey, px:String, milliseconds:Int):Promise<String> {})
	@:overload(function(key:RedisKey, value:RedisKey, exat:String, timestampSeconds:Int):Promise<String> {})
	@:overload(function(key:RedisKey, value:RedisKey, pxat:String, timestampMilliseconds:Int):Promise<String> {})
	@:overload(function(key:RedisKey, value:RedisKey, nx:String):Promise<Null<String>> {})
	@:overload(function(key:RedisKey, value:RedisKey, xx:String):Promise<Null<String>> {})
	@:overload(function(key:RedisKey, value:RedisKey, get:String):Promise<Null<String>> {})
	@:overload(function(key:RedisKey, value:RedisKey, keepttl:String):Promise<String> {})
	function set(key:RedisKey, value:RedisKey, ...options:String):Promise<EitherType<String, Null<String>>>;

	/**
	 * Delete a key
	 * @param key The key to delete
	 * @returns Promise that resolves with the number of keys removed
	 */
	function del(key:RedisKey):Promise<Int>;

	/**
	 * Increment the integer value of a key by one
	 * @param key The key to increment
	 * @returns Promise that resolves with the new value
	 */
	function incr(key:RedisKey):Promise<Int>;

	/**
	 * Decrement the integer value of a key by one
	 * @param key The key to decrement
	 * @returns Promise that resolves with the new value
	 */
	function decr(key:RedisKey):Promise<Int>;

	/**
	 * Determine if a key exists
	 * @param key The key to check
	 * @returns Promise that resolves with true if the key exists, false otherwise
	 */
	function exists(key:RedisKey):Promise<Bool>;

	/**
	 * Set a key's time to live in seconds
	 * @param key The key to set the expiration for
	 * @param seconds The number of seconds until expiration
	 * @returns Promise that resolves with 1 if the timeout was set, 0 if not
	 */
	function expire(key:RedisKey, seconds:Int):Promise<Int>;

	/**
	 * Get the time to live for a key in seconds
	 * @param key The key to get the TTL for
	 * @returns Promise that resolves with the TTL, -1 if no expiry, or -2 if key doesn't exist
	 */
	function ttl(key:RedisKey):Promise<Int>;

	/**
	 * Set multiple hash fields to multiple values
	 * @param key The hash key
	 * @param fieldValues An array of alternating field names and values
	 * @returns Promise that resolves with "OK" on success
	 */
	function hmset(key:RedisKey, fieldValues:Array<String>):Promise<String>;

	/**
	 * Get the values of all the given hash fields
	 * @param key The hash key
	 * @param fields The fields to get
	 * @returns Promise that resolves with an array of values
	 */
	function hmget(key:RedisKey, fields:Array<String>):Promise<Array<Null<String>>>;

	/**
	 * Check if a value is a member of a set
	 * @param key The set key
	 * @param member The member to check
	 * @returns Promise that resolves with true if the member exists, false otherwise
	 */
	function sismember(key:RedisKey, member:String):Promise<Bool>;

	/**
	 * Add a member to a set
	 * @param key The set key
	 * @param member The member to add
	 * @returns Promise that resolves with 1 if the member was added, 0 if it already existed
	 */
	function sadd(key:RedisKey, member:String):Promise<Int>;

	/**
	 * Remove a member from a set
	 * @param key The set key
	 * @param member The member to remove
	 * @returns Promise that resolves with 1 if the member was removed, 0 if it didn't exist
	 */
	function srem(key:RedisKey, member:String):Promise<Int>;

	/**
	 * Get all the members in a set
	 * @param key The set key
	 * @returns Promise that resolves with an array of all members
	 */
	function smembers(key:RedisKey):Promise<Array<String>>;

	/**
	 * Get a random member from a set
	 * @param key The set key
	 * @returns Promise that resolves with a random member, or null if the set is empty
	 */
	function srandmember(key:RedisKey):Promise<Null<String>>;

	/**
	 * Remove and return a random member from a set
	 * @param key The set key
	 * @returns Promise that resolves with the removed member, or null if the set is empty
	 */
	function spop(key:RedisKey):Promise<Null<String>>;

	/**
	 * Increment the integer value of a hash field by the given number
	 * @param key The hash key
	 * @param field The field to increment
	 * @param increment The amount to increment by
	 * @returns Promise that resolves with the new value
	 */
	function hincrby(key:RedisKey, field:String, increment:EitherType<String, Int>):Promise<Int>;

	/**
	 * Increment the float value of a hash field by the given amount
	 * @param key The hash key
	 * @param field The field to increment
	 * @param increment The amount to increment by
	 * @returns Promise that resolves with the new value as a string
	 */
	function hincrbyfloat(key:RedisKey, field:String, increment:EitherType<String, Float>):Promise<String>;

	/**
	 * Get all the fields and values in a hash
	 * @param key The hash key
	 * @returns Promise that resolves with an object containing all fields and values
	 */
	function hgetall(key:RedisKey):Promise<Null<DynamicAccess<String>>>;

	/**
	 * Get all field names in a hash
	 * @param key The hash key
	 * @returns Promise that resolves with an array of field names
	 */
	function hkeys(key:RedisKey):Promise<Array<String>>;

	/**
	 * Get the number of fields in a hash
	 * @param key The hash key
	 * @returns Promise that resolves with the number of fields
	 */
	function hlen(key:RedisKey):Promise<Int>;

	/**
	 * Get all values in a hash
	 * @param key The hash key
	 * @returns Promise that resolves with an array of values
	 */
	function hvals(key:RedisKey):Promise<Array<String>>;

	/**
	 * Find all keys matching the given pattern
	 * @param pattern The pattern to match
	 * @returns Promise that resolves with an array of matching keys
	 */
	function keys(pattern:String):Promise<Array<String>>;

	/**
	 * Get the length of a list
	 * @param key The list key
	 * @returns Promise that resolves with the length of the list
	 */
	function llen(key:RedisKey):Promise<Int>;

	/**
	 * Remove and get the first element in a list
	 * @param key The list key
	 * @returns Promise that resolves with the first element, or null if the list is empty
	 */
	function lpop(key:RedisKey):Promise<Null<String>>;

	/**
	 * Remove the expiration from a key
	 * @param key The key to persist
	 * @returns Promise that resolves with 1 if the timeout was removed, 0 if the key doesn't exist or has no timeout
	 */
	function persist(key:RedisKey):Promise<Int>;

	/**
	 * Get the expiration time of a key as a UNIX timestamp in milliseconds
	 * @param key The key to check
	 * @returns Promise that resolves with the timestamp, or -1 if the key has no expiration, or -2 if the key doesn't exist
	 */
	function pexpiretime(key:RedisKey):Promise<Int>;

	/**
	 * Get the time to live for a key in milliseconds
	 * @param key The key to check
	 * @returns Promise that resolves with the TTL in milliseconds, or -1 if the key has no expiration, or -2 if the key doesn't exist
	 */
	function pttl(key:RedisKey):Promise<Int>;

	/**
	 * Remove and get the last element in a list
	 * @param key The list key
	 * @returns Promise that resolves with the last element, or null if the list is empty
	 */
	function rpop(key:RedisKey):Promise<Null<String>>;

	/**
	 * Get the number of members in a set
	 * @param key The set key
	 * @returns Promise that resolves with the cardinality (number of elements) of the set
	 */
	function scard(key:RedisKey):Promise<Int>;

	/**
	 * Get the length of the value stored in a key
	 * @param key The key to check
	 * @returns Promise that resolves with the length of the string value, or 0 if the key doesn't exist
	 */
	function strlen(key:RedisKey):Promise<Int>;

	/**
	 * Get the number of members in a sorted set
	 * @param key The sorted set key
	 * @returns Promise that resolves with the cardinality (number of elements) of the sorted set
	 */
	function zcard(key:RedisKey):Promise<Int>;

	/**
	 * Remove and return members with the highest scores in a sorted set
	 * @param key The sorted set key
	 * @returns Promise that resolves with the removed member and its score, or null if the set is empty
	 */
	function zpopmax(key:RedisKey):Promise<Null<String>>;

	/**
	 * Remove and return members with the lowest scores in a sorted set
	 * @param key The sorted set key
	 * @returns Promise that resolves with the removed member and its score, or null if the set is empty
	 */
	function zpopmin(key:RedisKey):Promise<Null<String>>;

	/**
	 * Get one or multiple random members from a sorted set
	 * @param key The sorted set key
	 * @returns Promise that resolves with a random member, or null if the set is empty
	 */
	function zrandmember(key:RedisKey):Promise<Null<String>>;

	/**
	 * Append a value to a key
	 * @param key The key to append to
	 * @param value The value to append
	 * @returns Promise that resolves with the length of the string after the append operation
	 */
	function append(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Set the value of a key and return its old value
	 * @param key The key to set
	 * @param value The value to set
	 * @returns Promise that resolves with the old value, or null if the key didn't exist
	 */
	function getset(key:RedisKey, value:RedisKey):Promise<Null<String>>;

	/**
	 * Prepend one or multiple values to a list
	 * @param key The list key
	 * @param value The value to prepend
	 * @returns Promise that resolves with the length of the list after the push operation
	 */
	function lpush(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Prepend a value to a list, only if the list exists
	 * @param key The list key
	 * @param value The value to prepend
	 * @returns Promise that resolves with the length of the list after the push operation, or 0 if the list doesn't exist
	 */
	function lpushx(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Add one or more members to a HyperLogLog
	 * @param key The HyperLogLog key
	 * @param element The element to add
	 * @returns Promise that resolves with 1 if the HyperLogLog was altered, 0 otherwise
	 */
	function pfadd(key:RedisKey, element:String):Promise<Int>;

	/**
	 * Append one or multiple values to a list
	 * @param key The list key
	 * @param value The value to append
	 * @returns Promise that resolves with the length of the list after the push operation
	 */
	function rpush(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Append a value to a list, only if the list exists
	 * @param key The list key
	 * @param value The value to append
	 * @returns Promise that resolves with the length of the list after the push operation, or 0 if the list doesn't exist
	 */
	function rpushx(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Set the value of a key, only if the key does not exist
	 * @param key The key to set
	 * @param value The value to set
	 * @returns Promise that resolves with 1 if the key was set, 0 if the key was not set
	 */
	function setnx(key:RedisKey, value:RedisKey):Promise<Int>;

	/**
	 * Get the score associated with the given member in a sorted set
	 * @param key The sorted set key
	 * @param member The member to get the score for
	 * @returns Promise that resolves with the score of the member as a string, or null if the member or key doesn't exist
	 */
	function zscore(key:RedisKey, member:String):Promise<Null<String>>;

	/**
	 * Get the values of all specified keys
	 * @param keys The keys to get
	 * @returns Promise that resolves with an array of values, with null for keys that don't exist
	 */
	function mget(...keys:RedisKey):Promise<Array<Null<String>>>;

	/**
	 * Count the number of set bits (population counting) in a string
	 * @param key The key to count bits in
	 * @returns Promise that resolves with the number of bits set to 1
	 */
	function bitcount(key:RedisKey):Promise<Int>;

	/**
	 * Return a serialized version of the value stored at the specified key
	 * @param key The key to dump
	 * @returns Promise that resolves with the serialized value, or null if the key doesn't exist
	 */
	function dump(key:RedisKey):Promise<Null<String>>;

	/**
	 * Get the expiration time of a key as a UNIX timestamp in seconds
	 * @param key The key to check
	 * @returns Promise that resolves with the timestamp, or -1 if the key has no expiration, or -2 if the key doesn't exist
	 */
	function expiretime(key:RedisKey):Promise<Int>;

	/**
	 * Get the value of a key and delete the key
	 * @param key The key to get and delete
	 * @returns Promise that resolves with the value of the key, or null if the key doesn't exist
	 */
	function getdel(key:RedisKey):Promise<Null<String>>;

	/**
	 * Get the value of a key and optionally set its expiration
	 * @param key The key to get
	 * @returns Promise that resolves with the value of the key, or null if the key doesn't exist
	 */
	function getex(key:RedisKey):Promise<Null<String>>;
}
