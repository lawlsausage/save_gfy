import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/file_service.dart';
import 'package:save_gfy/values/app_config.dart';

class MockFileService extends Mock implements FileService {}

Map<String, dynamic> mockConfig() {
  return {
    'defaultUrl': mockString(),
    'gfycat': {'hosts': mockRange(mockString, mockInteger(1, 5))},
    'reddit': {'hosts': mockRange(mockString, mockInteger(1, 5))},
  };
}

void main() {
  group('AppConfig', () {
    group('fromJson', () {
      test('successfully parses valid JSON', () {
        final mockedDefaultUrl = mockString();
        final mockedGfycatHosts =
            mockRange<String>(mockString, mockInteger(1, 5));
        final mockedRedditHosts =
            mockRange<String>(mockString, mockInteger(1, 5));
        final mockedLogLevel = mockString();
        final jsonString = '{'
            '    "defaultUrl": "$mockedDefaultUrl",'
            '    "gfycat": {'
            '        "hosts": ${jsonEncode(mockedGfycatHosts)}'
            '    },'
            '    "reddit": {'
            '        "hosts": ${jsonEncode(mockedRedditHosts)}'
            '    },'
            '    "logLevel": "$mockedLogLevel"'
            '}';
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final result = AppConfig.fromJson(json);

        expect(result, isNotNull);
        expect(result.defaultUrl, equals(mockedDefaultUrl));
        expect(result.logLevel, equals(mockedLogLevel));
      });

      test('defaults logLevel to error', () {
        final jsonString = '{'
            '    "defaultUrl": "test",'
            '    "gfycat": {'
            '        "hosts": ["test"]'
            '    },'
            '    "reddit": {'
            '        "hosts": ["test"]'
            '    }'
            '}';
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final result = AppConfig.fromJson(json);

        expect(result, isNotNull);
        expect(result.logLevel, equals('error'));
      });

      test('defaults defaultUrl to null', () {
        final jsonString = '{'
            '    "gfycat": {'
            '        "hosts": ["test"]'
            '    },'
            '    "reddit": {'
            '        "hosts": ["test"]'
            '    }'
            '}';
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final result = AppConfig.fromJson(json);

        expect(result, isNotNull);
        expect(result.defaultUrl, isNull);
      });
    });

    group('forEnvironment', () {
      test('returns AppConfig for provided env', () async {
        final fileService = MockFileService();
        final mockedEnvironment = mockString(3);
        final mockedBaseConfig = mockConfig();
        final mockedLocalConfig = mockConfig();
        final mockedJsonConfigData = [
          {
            'path': 'assets/config/$mockedEnvironment.json',
            'config': mockedBaseConfig,
          },
          {
            'path': 'assets/config/$mockedEnvironment-local.json',
            'config': mockedLocalConfig,
          },
        ];
        var loadJsonFileCount = 0;

        mockedJsonConfigData.forEach((data) {
          when(fileService.loadJsonFile(data['path'])).thenAnswer((_) async {
            loadJsonFileCount += 1;
            return data['config'];
          });
        });

        final result =
            await AppConfig.forEnvironment(fileService, mockedEnvironment);

        expect(result, isNotNull);
        expect(result.defaultUrl, mockedLocalConfig['defaultUrl']);
        expect(loadJsonFileCount, equals(2));
      });
    });

    test('returns AppConfig without [env]-local.json file present', () async {
      final fileService = MockFileService();
      final mockedEnvironment = mockString(3);
      final mockedBaseConfig = mockConfig();
      final mockedJsonConfigData = [
        {
          'path': 'assets/config/$mockedEnvironment.json',
          'config': mockedBaseConfig,
        },
        {
          'path': 'assets/config/$mockedEnvironment-local.json',
          'config': null,
        },
      ];
      var loadJsonFileCount = 0;

      mockedJsonConfigData.forEach((data) {
        when(fileService.loadJsonFile(data['path'])).thenAnswer((_) async {
          loadJsonFileCount += 1;
          return data['config'];
        });
      });

      final result =
          await AppConfig.forEnvironment(fileService, mockedEnvironment);

      expect(result, isNotNull);
      expect(result.defaultUrl, mockedBaseConfig['defaultUrl']);
      expect(loadJsonFileCount, equals(2));
    });
  });
}
