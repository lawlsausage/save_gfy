import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/file_service.dart';
import 'package:save_gfy/services/logger_service.dart';

import '../config.dart';
import '../mocks/mock_file_service.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

class MockLoggerService extends Mock implements LoggerService {}

File _fileFactory(String filePath) => MockFile(filePath: filePath);

void main() {
  configureEnvironment();

  group('FileService', () {
    group('loadJsonFile', () {
      test('reads JSON file into object', () async {
        final mockJson = {
          'property1': 'hello',
          'property2': [
            'world',
            'galaxy',
          ],
        };
        final mockDirectory = mockString();
        final mockFilePath = '$mockDirectory/test.json';
        final mockAssetBundle = MockAssetBundle();

        when(mockAssetBundle.loadString(argThat(equals(mockFilePath))))
            .thenAnswer((_) async => Future.value(jsonEncode(mockJson)));

        final service = FileService(_fileFactory, MockLoggerService(),
            appAssetBundle: mockAssetBundle);
        final json = await service.loadJsonFromFile(mockFilePath);

        expect(json, isNotNull);
        expect(json, equals(mockJson));
      });

      test('reads JSON file into List', () async {
        final mockJsonList = [
          {
            'property1': 'hello',
            'property2': [
              'world',
              'galaxy',
            ],
          },
          {
            'property1': 'foo',
            'property2': [
              'bar',
              'baz',
            ],
          },
        ];
        final mockDirectory = mockString();
        final mockFilePath = '$mockDirectory/test.json';
        final mockAssetBundle = MockAssetBundle();

        when(mockAssetBundle.loadString(argThat(equals(mockFilePath))))
            .thenAnswer((_) async => Future.value(jsonEncode(mockJsonList)));

        final service = FileService(_fileFactory, MockLoggerService(),
            appAssetBundle: mockAssetBundle);
        final json = await service.loadJsonFromFile(mockFilePath);

        expect(json, isNotNull);
        expect(json, equals(mockJsonList));
      });

      test('handles exceptions and returns empty Map object', () async {
        final mockDirectory = mockString();
        final mockFilePath = '$mockDirectory/test.json';
        final mockAssetBundle = MockAssetBundle();

        when(mockAssetBundle.loadString(argThat(equals(mockFilePath))))
            .thenAnswer(
                (_) async => Future.value('too many chickens in the road'));

        final service = FileService(_fileFactory, MockLoggerService(),
            appAssetBundle: mockAssetBundle);
        final json = await service.loadJsonFromFile(mockFilePath);

        expect(json, isNotNull);
        expect(json, isA<Map<String, dynamic>>());
        expect((json as Map<String, dynamic>).keys.length, equals(0));
      });
    });

    group('createFile', () {
      test('creates a File instance with the provided path', () {
        final mockedDirectory = mockString();
        final mockedFilePath = '$mockedDirectory/test.txt';
        final service = FileService(_fileFactory, MockLoggerService(),
            appAssetBundle: MockAssetBundle());
        final file = service.instance(mockedFilePath);

        expect(file, isNotNull);
        expect(file.path, equals(mockedFilePath));
      });
    });

    group('deleteFileSync', () {
      test('deletes an existing file from underlying file system', () {
        final mockFile = MockFile();
        int deleteCount = 0;

        when(mockFile.existsSync()).thenReturn(true);
        when(mockFile.deleteSync(recursive: anyNamed('recursive')))
            .thenAnswer((_) {
          deleteCount += 1;
        });

        final service = FileService(_fileFactory, MockLoggerService(),
            appAssetBundle: MockAssetBundle());
        final file = service.deleteFileSync(mockFile);

        expect(deleteCount, equals(1));
        expect(file, isNotNull);
      });

      test('takes no action on file which does not exist', () {
        final mockFile = MockFile();
        int deleteCount = 0;

        when(mockFile.existsSync()).thenReturn(false);
        when(mockFile.deleteSync(recursive: anyNamed('recursive')))
            .thenAnswer((_) {
          deleteCount += 1;
        });

        final service = FileService(_fileFactory, MockLoggerService(),
            appAssetBundle: MockAssetBundle());
        final file = service.deleteFileSync(mockFile);

        expect(deleteCount, equals(0));
        expect(file, isNotNull);
      });
    });
  });
}
