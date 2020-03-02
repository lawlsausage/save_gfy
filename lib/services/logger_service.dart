import 'package:logger/logger.dart';

/// LoggerService is a light wrapper class layer to the [Logger] class.
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

  /// Closes the [Logger] instance.
  ///
  /// > __WARNING__: This releases the resources of the [Logger] instance
  /// provided. Ensure that this is called at the highest most possible part
  /// of the application such as the main method. See also: [Logger.close]
  void close() {
    _logger.close();
  }

  /// See: [Logger.d]
  void d(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  /// See: [Logger.e]
  void e(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  /// See: [Logger.i]
  void i(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  /// See: [Logger.v]
  void v(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.v(message, error, stackTrace);
  }

  /// See: [Logger.w]
  void w(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.w(message, error, stackTrace);
  }

  /// See: [Logger.wtf]
  void wtf(dynamic message, [dynamic error, StackTrace stackTrace]) {
    _logger.wtf(message, error, stackTrace);
  }
}
