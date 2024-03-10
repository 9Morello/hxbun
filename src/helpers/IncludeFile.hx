package helpers;

import sys.FileSystem;
import haxe.macro.Compiler;
import sys.io.File;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.io.Path;

#if !macro macro #end function includeFile(filename:String):Expr {
	var posInfos = Context.getPosInfos(Context.currentPos());
	var directory = Path.directory(posInfos.file);
	final filePath = directory + "/" + filename;
	final outputDirectory = Path.directory(Compiler.getOutput());
	if (!FileSystem.exists(outputDirectory)) {
		FileSystem.createDirectory(outputDirectory);
	}
	final compilerOutputDir = Path.directory(Compiler.getOutput());
	final destinationPath = (compilerOutputDir != "") ? '$compilerOutputDir/$filename' : filename;
	File.copy(filePath, destinationPath);
	// @:privateAccess Context.includeFile(filePath, "closure");
	return macro {};
}
