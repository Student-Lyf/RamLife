// ignore_for_file: avoid_print

/// A container for ANSI color codes. 
/// 
/// To use this class, pass in an ANSI color code into [AnsiColor.fg] or 
/// [AnsiColor.bg], and then use [AnsiColor.colorMessage]..
/// Example: 
/// 
/// ```dart
/// void main() {
///   final int fgColor = 123;  // the color code for the foreground
///   final AnsiColor fg = AnsiColor.fg(fgColor);
///   final String message = "Hello, World!";
///   final String coloredMessage = fg.colorMessage(message);
/// }
/// ```
/// 
/// Currently, only the background _or_ the foreground color can be changed, not
/// both at the same time.
class AnsiColor {
  /// The ANSI Control Sequence Introducer.
  /// 
  /// The terminal interprets this code as the beginning of ANSI instructions. 
  static const ansiEsc = "\x1B[";

  /// Resets all terminal settings back to their defaults.
  static const ansiDefault = "${ansiEsc}0m";

  /// Returns the terminal to its default foreground color.
  static String get resetForeground => "${ansiEsc}39m";

  /// Returns the terminal to its default background color.
  static String get resetBackground => "${ansiEsc}49m";

  /// Returns a level of grey. 
  /// 
  /// Pass in a value between 0 and 1, with 0 being white and 1 being black.
  static int grey(double level) => 232 + (level.clamp(0.0, 1.0) * 23).round();

  /// The foreground color.
  /// 
  /// If null, the default foreground color will be used.
  final int fg;

  /// The background color.
  /// 
  /// If null, the default background color will be used.
  final int bg;

  /// Creates an ANSI color code that modifies the foreground color.
  const AnsiColor.fg(this.fg) : 
    bg = null,
    assert(fg != null, "AnsiColor cannot have a null foreground");

  /// Creates an ANSI color code that modifies the background color.
  const AnsiColor.bg(this.bg) : 
    fg = null,
    assert(bg != null, "AnsiColor cannot have a null background");

  /// The ANSI color code that sets the foreground or background color.
  String get code => fg != null
    ? "${ansiEsc}38;5;${fg}m"
    : "${ansiEsc}48;5;${bg}m";

  /// Returns a new String with the ANSI color code injected. 
  /// 
  /// The terminal defaults after this String. 
  String colorMessage(String msg) => "$code$msg$ansiDefault";
}

/// A level for [Logger].
/// 
/// Do not construct this class directly, instead use its static constants.
/// 
/// This class is used by [Logger.level] and [Logger.log].
class LogLevel {
  /// The debug log level.
  /// 
  /// This level outputs important values, along with their names, so that if
  /// the code fails, it will be obvious which value was unexpected.
  /// 
  /// This is lower than the default value, since if everything works, this is 
  /// not needed and can get distracting. 
	static const LogLevel debug = LogLevel(0, "D", AnsiColor.fg(15)); 

  /// The verbose log level.
  /// 
  /// This level outputs descriptions of the progress of the code at a given 
  /// point at a very low level, so that if something fails, the logs can show
  /// exactly what led up to it.
  /// 
  /// This is lower than the default level, since if everything works, 
  /// this is not needed and can get distracting. 
  static const LogLevel verbose = LogLevel(1, "V", AnsiColor.fg(244));

  /// The informative log level. 
  /// 
  /// This level outputs helpful messages about the progress of the code at a 
  /// high level, offering the perfect balance between loading indicator and 
  /// [LogLevel.verbose].
  /// 
  /// This is the default level.
	static const LogLevel info = LogLevel(2, "I", AnsiColor.fg(32));

  /// The warning log level.
  /// 
  /// This level outputs warnings that indicate that while the code may still 
  /// work, some values were unexpected and may or may not corrupt data, or 
  /// cause a future error.
  /// 
  /// This is higher than the default level, since it offers helpful notices of
  /// potential bugs, but technically the code still works. 
	static const LogLevel warning = LogLevel(3, "W", AnsiColor.fg(3));  // also 208

  /// The error log level. 
  /// 
  /// This level outputs errors that could not be handled by the program and 
  /// require a change in the inputs or code itself.
  /// 
  /// This should rarely be used. Instead, the error should be thrown to invoke
  /// the native error reporting and stack tracing. However, if for some reason 
  /// the program must continue running, this level can output the error while 
  /// allowing the code to proceed. It's most helpfully used in try/catch blocks.
	static const LogLevel error = LogLevel(4, "E", AnsiColor.fg(196));

  /// The color for this level. 
  /// 
  /// The color only affects [letter], the rest of the message is left alone.
	final AnsiColor color;

  /// The letter to show when a message at this level is logged. 
	final String letter;

  /// The level to log this message at. 
  /// 
  /// If [Logger.level] has a higher value than this, this message will not be 
  /// logged.
	final int value;

  /// Creates a log level with a unique value.
	const LogLevel(this.value, this.letter, this.color);

  /// If this level is higher or equal to another level.
  /// 
  /// This works by comparing [value] to [other].
	bool operator >= (LogLevel other) => value >= other.value;

  /// A prefix to insert before a message logged at this level.
  String get prefix => color?.colorMessage("[$letter]") ?? "[$letter]";
}

/// A class that logs messages to the console.
/// 
/// To log a message, use the method whose name matches the desired [LogLevel]. 
/// For example, to log a message at the debug level, use [debug]. 
/// However, those methods are simply wrappers around [log], which takes
/// any [LogLevel] as an argument. 
/// 
/// [shouldLog] determines if the message should be logged, depending on the 
/// level it is being logged at (using [level]). 
/// 
/// [getMessage] formats the message before logging it, using [LogLevel.prefix].
class Logger {
  /// The lowest level to log. 
  /// 
  /// See [shouldLog] for details.
	static LogLevel level = LogLevel.info;

  /// Combines [message] with [LogLevel.prefix] to create a new message.
	static String getMessage(LogLevel level, String message) => 
		"${level.prefix}: $message";

  /// Whether a message should be logged, based on its level.
  /// 
  /// Any level lower than [Logger.level] will not be logged.
	static bool shouldLog(LogLevel level) => level >= Logger.level;

  /// Logs a message at a given level.
	static void log(LogLevel level, String message) {
		if (shouldLog(level)) {
			print(getMessage(level, message));
		}
	}

  /// Logs a message at the verbose level. 
  /// 
  /// See [LogLevel.verbose] for details.
  static void verbose(String message) => log(LogLevel.verbose, message);

  /// Logs a message at the debug level. 
  /// 
  /// See [LogLevel.debug] for details.
	static void debug(String message) => log(LogLevel.debug, message);

  /// Logs a message at the informative level. 
  /// 
  /// See [LogLevel.info] for details.
	static void info(String message) => log(LogLevel.info, message);

  /// Logs a message at the warning level. 
  /// 
  /// See [LogLevel.warning] for details.
	static void warning(String message) => log(LogLevel.warning, message);

  /// Logs a message at the error level. 
  /// 
  /// See [LogLevel.error] for details.
	static void error(String message) => log(LogLevel.error, message);
}
