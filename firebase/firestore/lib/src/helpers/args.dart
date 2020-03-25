import "package:node_interop/node.dart";

import "logger.dart";

/// A container class for parsing arguments.
/// 
/// Since this app is to be compiled to JavaScript, Node.js methods need to be 
/// used to retrieve the arguments (instead of `main`). Instead, use [process] 
/// from the [`node_interop`](https://pub.dev/packages/node_interop) package.
/// 
/// [initLogger] should be called to actually use the values of the arguments. 
class Args {
	/// The list of arguments passed to the program.
	static final List<String> args = process.argv.sublist(2);

	/// Whether [args] contains any one of the following flags. 
	static bool inArgs(Set<String> flags) => flags.any(args.contains);

	/// Whether [Logger] should use color. 
	/// 
	/// [initLogger] passes this value to [AnsiColor.supportsColor].
	static final bool color = !inArgs({"--no-color"});

	/// Whether to upload the data to the cloud.
	static final bool upload = inArgs({"-u", "--upload"});

	/// If [Logger.level] should be set to [LogLevel.verbose].
	static final bool verbose = inArgs({"-v", "--verbose"});
	
	/// If [Logger.level] should be set to [LogLevel.debug].
	static final bool debug = inArgs({"-d", "--debug"});

	/// Initializes the logger based on the static properties of this class.
	static void initLogger() {
		AnsiColor.supportsColor = color;
		if (debug) {
			Logger.level = LogLevel.debug;
		} else if (verbose) {
			Logger.level = LogLevel.verbose;
		}
		Logger.debug("upload", upload);
	}
}
