// ignore_for_file: avoid_print

class AnsiColor {
  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const ansiEsc = "\x1B[";

  /// Reset all colors and options for current SGRs to terminal defaults.
  static const ansiDefault = "${ansiEsc}0m";

  final int fg;
  final int bg;
  final bool color;

  const AnsiColor.none()
      : fg = null,
        bg = null,
        color = false;

  const AnsiColor.fg(this.fg)
      : bg = null,
        color = true;

  const AnsiColor.bg(this.bg)
      : fg = null,
        color = true;

  @override
  String toString() {
    if (fg != null) {
      return "${ansiEsc}38;5;${fg}m";
    } else if (bg != null) {
      return "${ansiEsc}48;5;${bg}m";
    } else {
      return "";
    }
  }

  String call(String msg) {
    if (color) {
      return "${this}$msg$ansiDefault";
    } else {
      return msg;
    }
  }

  AnsiColor toFg() => AnsiColor.fg(bg);

  AnsiColor toBg() => AnsiColor.bg(fg);

  /// Defaults the terminal's foreground color without altering the background.
  String get resetForeground => color ? "${ansiEsc}39m" : "";

  /// Defaults the terminal's background color without altering the foreground.
  String get resetBackground => color ? "${ansiEsc}49m" : "";

  static int grey(double level) => 232 + (level.clamp(0.0, 1.0) * 23).round();
}

class LogLevel {
  static const LogLevel verbose = LogLevel(0, "V", AnsiColor.fg(244));
	static const LogLevel debug = LogLevel(1, "D", AnsiColor.none()); 
	static const LogLevel info = LogLevel(2, "I", AnsiColor.fg(12));
	// static const LogLevel warning = LogLevel(3, "W", AnsiColor.fg(208));
	static const LogLevel warning = LogLevel(3, "W", AnsiColor.fg(3));
	static const LogLevel error = LogLevel(4, "E", AnsiColor.fg(196));

	final AnsiColor color;
	final String prefix;
	final int value;
	const LogLevel(this.value, this.prefix, this.color);

	bool operator >= (LogLevel other) => value >= other.value;

}

class Logger {
	static LogLevel level = LogLevel.info;

	static String getMessage(LogLevel level, String message) => 
		"${level.color('[${level.prefix}]')}: $message";

	static bool shouldLog(LogLevel level) => level >= Logger.level;

	static void log(LogLevel level, String message) {
		if (shouldLog(level)) {
			print(getMessage(level, message));
		}
	}

	static void debug(String message) => log(LogLevel.debug, message);
	static void info(String message) => log(LogLevel.info, message);
	static void warning(String message) => log(LogLevel.warning, message);
	static void error(String message) => log(LogLevel.error, message);
}
