import 'package:save_gfy/services/logger_service.dart';
import 'package:save_gfy/values/app_config.dart';
import 'package:save_gfy/values/config.dart';

/// [ConfigService] is a service which provides the application's
/// configuration context. Most notably, [AppConfig] may be found in the
/// [appConfig] property and accessible to other modules throughout the application.
class ConfigService {
  final Map<String, Config> configs = <String, Config>{};

  get appConfig => _appConfig;
  AppConfig _appConfig;
  /// [appConfig] provides a setter, but the property may only be assigned 
  /// once throughout the whole application. Any other attempts to reassign
  /// [appConfig] through the setter will be ignored.
  set appConfig(AppConfig value) {
    if (_appConfig != null) {
      loggerService.w('[ConfigService.appConfig] may only be assigned once '
          'in the application. All other assignments are ignored');
      return;
    }

    _appConfig = value;
  }
}
