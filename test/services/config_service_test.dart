import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/config_service.dart';
import 'package:save_gfy/values/app_config.dart';
import 'package:save_gfy/values/config.dart';

import '../config.dart';

class MockConfig extends Mock implements Config {}

class MockAppConfig extends Mock implements AppConfig {}

void main() {
  configureEnvironment();

  group('ConfigService', () {
    group('appConfig', () {
      test('assigns AppConfig to [appConfig]', () {
        final mockAppConfig = MockAppConfig();
        final service = ConfigService();

        service.appConfig = mockAppConfig;
        expect(service.appConfig, equals(mockAppConfig));
      });

      test('second assignment of [appConfig] will be ignored', () {
        final mockAppConfig1 = MockAppConfig();
        final mockAppConfig2 = MockAppConfig();
        final service = ConfigService();

        service.appConfig = mockAppConfig1;
        service.appConfig = mockAppConfig2;
        expect(identical(service.appConfig, mockAppConfig1), isTrue);
      });
    });
  });
}
