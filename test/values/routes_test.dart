import 'package:flutter_test/flutter_test.dart';
import 'package:save_gfy/values/routes.dart';

void main() {
  group('Route', () {
    test('Route.home.path returns /', () {
      expect(Route.home.path, equals('/'));
    });

    test('Route.pasteUrl returns /pasteUrl', () {
      expect(Route.pasteUrl.path, equals('/pasteUrl'));
    });
  });
}
