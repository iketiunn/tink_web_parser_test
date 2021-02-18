package;

import tink.cli.*;
import tink.Cli;

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
		var rootHx = rest[0];
		if (rootHx == null)  {
			// Or print help
			Sys.println('Please input a file path!');
		} else {
			// Path validation

			// Call Parse

			// Print the result
			Sys.println('rootHx: $rootHx');
		}
	}
}