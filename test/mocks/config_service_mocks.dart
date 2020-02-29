import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/config_service.dart';
import 'package:save_gfy/values/app_config.dart';
import 'package:save_gfy/values/app_site_config.dart';

class MockAppConfig extends Mock implements AppConfig {
  MockAppConfig setupDefaultUrl(String url) {
    when(this.defaultUrl).thenReturn(url);
    return this;
  }

  MockAppConfig setupGfycatAppSiteConfig(
      {MockAppSiteConfig Function(MockAppSiteConfig) onSetupAppSiteConfig}) {
    final mockAppSiteConfig =
        _setupAppSiteConfig(onSetupAppSiteConfig: onSetupAppSiteConfig);
    when(this.gfycat).thenReturn(mockAppSiteConfig);
    return this;
  }

  MockAppConfig setupRedditAppSiteConfig(
      {MockAppSiteConfig Function(MockAppSiteConfig) onSetupAppSiteConfig}) {
    final mockAppSiteConfig =
        _setupAppSiteConfig(onSetupAppSiteConfig: onSetupAppSiteConfig);
    when(this.reddit).thenReturn(mockAppSiteConfig);
    return this;
  }

  MockAppConfig setupLogLevel(String logLevel) {
    when(this.logLevel).thenReturn(logLevel);
    return this;
  }

  MockAppSiteConfig _setupAppSiteConfig(
      {MockAppSiteConfig Function(MockAppSiteConfig) onSetupAppSiteConfig}) {
    var mockAppSiteConfig = MockAppSiteConfig();
    // Allow the callback to return `null` if that is the desired action.
    if (onSetupAppSiteConfig != null) {
      mockAppSiteConfig = onSetupAppSiteConfig.call(mockAppSiteConfig);
    }
    return mockAppSiteConfig;
  }
}

class MockAppSiteConfig extends Mock implements AppSiteConfig {
  MockAppSiteConfig setupHosts(List<String> hosts) {
    when(this.hosts).thenReturn(hosts);
    return this;
  }
}

class MockConfigService extends Mock implements ConfigService {}

class ConfigServiceMocks {
  final mockAppConfig = MockAppConfig();
  final mockConfigService = MockConfigService();

  ConfigServiceMocks setup() {
    when(mockConfigService.appConfig).thenReturn(mockAppConfig);
    return this;
  }
}
