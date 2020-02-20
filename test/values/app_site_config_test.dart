import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:save_gfy/values/app_site_config.dart';

void main() {
  group('AppSiteConfig', () {
    group('fromJson', () {
      test('returns AppSiteConfig from valid JSON', () {
        final mockedJson = {
          'hosts': mockRange<String>(mockString, mockInteger(1, 10)),
        };
        final result = AppSiteConfig.fromJson(mockedJson);

        expect(result, isNotNull);
        expect(result.hosts, hasLength(mockedJson['hosts'].length));
        result.hosts.asMap().forEach((index, value) {
          expect(value, equals(mockedJson['hosts'][index]));
        });
      });

      test('returns null for null [json] parameter', () {
        final result = AppSiteConfig.fromJson(null);

        expect(result, isNull);
      });

      test('null hosts JSON property will be empty [AppSiteConfig.hosts]', () {
        final mockedJson1 = {
          'hosts': null,
        };
        final mockedJson2 = Map<String, dynamic>();
        final result1 = AppSiteConfig.fromJson(mockedJson1);
        final result2 = AppSiteConfig.fromJson(mockedJson2);

        expect(result1, isNotNull);
        expect(result1.hosts, isEmpty);
        expect(result2, isNotNull);
        expect(result2.hosts, isEmpty);
      });
    });
  });
}