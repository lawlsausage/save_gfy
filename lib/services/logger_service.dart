import 'package:logger/logger.dart';

/// LoggerService is a light abstraction layer to the logger package.
class LoggerService {
  LoggerService(this._logger);

  final Logger _logger;

  static const Map<String, Level> levels = {
    'debug': Level.debug,
    'error': Level.error,
    'info': Level.info,
    'nothing': Level.nothing,
    'verbose': Level.verbose,
    'warning': Level.warning,
    'wtf': Level.wtf,
  };

  close() {
    _logger.close();
  }

  d(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  e(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  i(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  v(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.v(message, error, stackTrace);
  }

  w(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.w(message, error, stackTrace);
  }

  wtf(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.wtf(message, error, stackTrace);
  }
}
