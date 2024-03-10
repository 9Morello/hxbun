package helpers;

@:js.customImport(@star "./query-parser") extern class QueryParser {
	public static function parse(input:String):Dynamic;

	private static function __init__():Void {
		IncludeFile.includeFile("query-parser.js");
	}
}
