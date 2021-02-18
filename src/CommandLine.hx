package;

import tink.cli.*;
import tink.Cli;
import sys.io.File;

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
			// Path validation
			var root = File.getContent(rootPath);

			// Call Parse

			// Print the result
			Sys.println('rootPath: $rootPath');
		}
	}
}