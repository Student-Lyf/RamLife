import "package:logger/logger.dart";

/// The logger to use across this app.
/// 
/// [ReleaseFilter] allows it to log even in release mode.
final Logger logger = Logger(filter: ReleaseFilter(), printer: SimplePrinter());

/// A [LogFilter] that logs even in release mode.
class ReleaseFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}