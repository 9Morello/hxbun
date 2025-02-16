package js.html;

/**
* Sets how binary data is returned in events.
*
* - if `NodeBuffer`, binary data is returned as `Buffer` objects. **(default)**
* - if `ArrayBuffer`, binary data is returned as `ArrayBuffer` objects.
* - if `UInt8Array`, binary data is returned as `Uint8Array` objects.
*/
enum abstract BinaryType(String) {
    final NodeBuffer = "nodebuffer";
    final ArrayBuffer = "arraybuffer";
    final UInt8Array =  "uint8array";
}