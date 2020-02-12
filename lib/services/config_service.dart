import 'package:save_gfy/values/app_config.dart';
import 'package:save_gfy/values/config.dart';

class ConfigService {
  const ConfigService();

  static final Map<String, Config> _configs = <String, Config>{};

  void setAppConfig(AppConfig config) {
    _configs['app'] = config;
  }

  AppConfig getAppConfig() {
    return _configs['app'] as AppConfig;
  }
}
