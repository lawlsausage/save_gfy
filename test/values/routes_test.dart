import 'package:flutter_test/flutter_test.dart';
import 'package:save_gfy/values/routes.dart';

import '../config.dart';

void main() {
  configureEnvironment(); 
  
  group('Route', () {
    test('Route.home.path returns /', () {
      expect(Route.home.path, equals('/'));
    });

    test('Route.pasteUrl returns /pasteUrl', () {
      expect(Route.pasteUrl.path, equals('/pasteUrl'));
    });
  });
}
