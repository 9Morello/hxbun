package bun.processes;

/**
 * Type of serialization for IPC messages.
 **/
enum abstract IPCMessageSerializationType(String) from String to String {
	final JSON = "json";
	final ADVANCED = "advanced";
}