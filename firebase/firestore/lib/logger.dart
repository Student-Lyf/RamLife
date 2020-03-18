import "package:logger/logger.dart";

final Logger logger = Logger(filter: ReleaseFilter(), printer: SimplePrinter());

class ReleaseFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}