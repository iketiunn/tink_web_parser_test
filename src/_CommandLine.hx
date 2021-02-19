// package;
import sys.io.File;
import tink.cli.*;
import tink.Cli;
import Parser;

class CommandLine {
    static function main() {
        Cli.process(Sys.args(), new Cmd()).handle(Cli.exit);
    }
}


@:alias(false)
class Cmd {
	public function new() {}
	
	@:defaultCommand
	public function run(rest:Rest<String>) {
		var rootPath = rest[0];
		if (rootPath == null)  {
			// Or print help
			Sys.println('Please input a file path!');
		} else {
			// Path validation to get the class path
			// Or just pass class path

			// var root = File.getContent(rootPath);
			// Sys.println(root);
			// var t = Type.resolveClass('server.api.Public');
			// trace(
			// 	t
			// );
			

			// Call Parse
			Parser.parse('rootPath');
			// Parser.parse('server.api.Public');

			// Print the result
			// Sys.println('rootPath: $rootPath');
		}
	}
}