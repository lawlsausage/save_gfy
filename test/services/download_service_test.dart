import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/download_service.dart';
import 'package:save_gfy/services/file_service.dart';
import 'package:save_gfy/services/logger_service.dart';

import '../config.dart';
import '../mocks/mock_http_client.dart';

class MockFileService extends Mock implements FileService {}

class MockFile extends Mock implements File {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  configureEnvironment();

  group('DownloadService', () {
    group('downloadfile', () {
      test('saves data to file', () async {
        final mockedData = mockString(mockInteger(1, 100));
        final mockedDataAsBytes = utf8.encode(mockedData);
        final mockedUrl = 'https://${mockString()}';
        final mockedFilePath = mockString();
        final httpClientMocks = HttpClientMocks();
        final mockedFileService = MockFileService();
        final mockFile = MockFile();

        when(mockFile.path).thenReturn(mockedFilePath);
        when(mockFile.existsSync()).thenReturn(false);
        when(mockedFileService.createFile(mockedFilePath)).thenReturn(mockFile);

        httpClientMocks
          ..response
              .setupStatusCode(HttpStatus.ok)
              .setupContentLength(mockedData.length)
              .setupListen(mockedDataAsBytes)
          ..setup(mockedUrl);

        final service = DownloadService(
            httpClientMocks.httpClient, mockedFileService, MockLoggerService());
        final filePath = await service.downloadFile(
          url: mockedUrl,
          filePath: mockedFilePath,
        );

        expect(filePath, isNotNull);
        expect(filePath, equals(mockedFilePath));
      });

      test('invokes onDownloadStarted callback', () async {
        final mockedData = mockString(mockInteger(1, 100));
        final mockedDataAsBytes = utf8.encode(mockedData);
        final mockedUrl = 'https://${mockString()}';
        final mockedFilePath = mockString();
        final httpClientMocks = HttpClientMocks();
        final mockedFileService = MockFileService();
        final mockFile = MockFile();
        StreamSubscription mockedStreamSubscription;

        when(mockFile.path).thenReturn(mockedFilePath);
        when(mockFile.existsSync()).thenReturn(false);
        when(mockedFileService.createFile(mockedFilePath)).thenReturn(mockFile);

        httpClientMocks
          ..response
              .setupStatusCode(HttpStatus.ok)
              .setupContentLength(mockedData.length)
              .setupListen(
                mockedDataAsBytes,
                onCreateStreamSubscription: (subscription) =>
                    mockedStreamSubscription = subscription,
              )
          ..setup(mockedUrl);

        final service = DownloadService(
            httpClientMocks.httpClient, mockedFileService, MockLoggerService());
        final filePath = await service.downloadFile(
          url: mockedUrl,
          filePath: mockedFilePath,
          onDownloadStarted: (subscription, totalBytes) {
            expect(subscription, isNotNull);
            expect(subscription, equals(mockedStreamSubscription));
            expect(totalBytes, mockedDataAsBytes.length);
          },
        );

        expect(filePath, isNotNull);
        expect(filePath, equals(mockedFilePath));
      });

      test('invokes onDownloadProgress callback', () async {
        final mockedData = mockString(mockInteger(1, 100));
        final mockedDataAsBytes = utf8.encode(mockedData);
        final mockedUrl = 'https://${mockString()}';
        final mockedFilePath = mockString();
        final httpClientMocks = HttpClientMocks();
        final mockedFileService = MockFileService();
        final mockFile = MockFile();
        int progressCount = 0;

        when(mockFile.path).thenReturn(mockedFilePath);
        when(mockFile.existsSync()).thenReturn(false);
        when(mockedFileService.createFile(mockedFilePath)).thenReturn(mockFile);

        httpClientMocks
          ..response
              .setupStatusCode(HttpStatus.ok)
              .setupContentLength(mockedData.length)
              .setupListen(mockedDataAsBytes)
          ..setup(mockedUrl);

        final service = DownloadService(
            httpClientMocks.httpClient, mockedFileService, MockLoggerService());
        final filePath = await service.downloadFile(
          url: mockedUrl,
          filePath: mockedFilePath,
          onDownloadProgress: (receivedBytes, totalBytes) {
            progressCount += 1;
            expect(receivedBytes, greaterThanOrEqualTo(0));
            expect(receivedBytes, lessThanOrEqualTo(mockedDataAsBytes.length));
            expect(totalBytes, equals(mockedDataAsBytes.length));
          },
        );

        expect(filePath, isNotNull);
        expect(filePath, equals(mockedFilePath));
        expect(progressCount, greaterThan(0));
      });

      test('invokes onDownloadFinished callback', () async {
        final mockedData = mockString(mockInteger(1, 100));
        final mockedDataAsBytes = utf8.encode(mockedData);
        final mockedUrl = 'https://${mockString()}';
        final mockedFilePath = mockString();
        final httpClientMocks = HttpClientMocks();
        final mockedFileService = MockFileService();
        final mockFile = MockFile();
        int finishedCount = 0;

        when(mockFile.path).thenReturn(mockedFilePath);
        when(mockFile.existsSync()).thenReturn(false);
        when(mockedFileService.createFile(mockedFilePath)).thenReturn(mockFile);

        httpClientMocks
          ..response
              .setupStatusCode(HttpStatus.ok)
              .setupContentLength(mockedData.length)
              .setupListen(mockedDataAsBytes)
          ..setup(mockedUrl);

        final service = DownloadService(
            httpClientMocks.httpClient, mockedFileService, MockLoggerService());
        final filePath = await service.downloadFile(
            url: mockedUrl,
            filePath: mockedFilePath,
            onDownloadFinished: (filePath) {
              finishedCount += 1;
              expect(filePath, equals(mockedFilePath));
            });

        expect(filePath, isNotNull);
        expect(filePath, equals(mockedFilePath));
        expect(finishedCount, equals(1));
      });

      test('304 Not Modified finishes successfully', () async {
        final mockedData = mockString(mockInteger(1, 100));
        final mockedDataAsBytes = utf8.encode(mockedData);
        final mockedUrl = 'https://${mockString()}';
        final mockedFilePath = mockString();
        final httpClientMocks = HttpClientMocks();
        final mockedFileService = MockFileService();
        final mockFile = MockFile();

        when(mockFile.path).thenReturn(mockedFilePath);
        when(mockFile.existsSync()).thenReturn(false);
        when(mockedFileService.createFile(mockedFilePath)).thenReturn(mockFile);

        httpClientMocks
          ..response
              .setupStatusCode(HttpStatus.notModified)
              .setupContentLength(mockedData.length)
              .setupListen(mockedDataAsBytes)
          ..setup(mockedUrl);

        final service = DownloadService(
            httpClientMocks.httpClient, mockedFileService, MockLoggerService());
        final filePath = await service.downloadFile(
          url: mockedUrl,
          filePath: mockedFilePath,
        );

        expect(filePath, isNotNull);
        expect(filePath, equals(mockedFilePath));
      });

      test('throws error for status code other than 200 or 304', () async {
        final mockedData = mockString(mockInteger(1, 100));
        final mockedUrl = 'https://${mockString()}';
        final mockedFilePath = mockString();
        final httpClientMocks = HttpClientMocks();
        final mockedFileService = MockFileService();
        final mockFile = MockFile();
        final mockedStatusCode = HttpStatus.internalServerError;

        when(mockFile.path).thenReturn(mockedFilePath);
        when(mockFile.existsSync()).thenReturn(false);
        when(mockedFileService.createFile(mockedFilePath)).thenReturn(mockFile);

        httpClientMocks
          ..response
              .setupStatusCode(mockedStatusCode)
              .setupContentLength(mockedData.length)
          ..setup(mockedUrl);

        final service = DownloadService(
            httpClientMocks.httpClient, mockedFileService, MockLoggerService());
        expect(
          () async => await service.downloadFile(
            url: mockedUrl,
            filePath: mockedFilePath,
          ),
          throwsA(equals('$mockedStatusCode: Unable to download')),
        );
      });

      test('handles exceptions while downloading and deletes file if exists',
          () async {
        final mockedData = mockString(mockInteger(1, 100));
        final mockedDataAsBytes = utf8.encode(mockedData);
        final mockedUrl = 'https://${mockString()}';
        final mockedFilePath = mockString();
        final httpClientMocks = HttpClientMocks();
        final mockedFileService = MockFileService();
        final mockFile = MockFile();
        final mockedStatusCode = HttpStatus.ok;
        int deleteCount = 0;

        when(mockFile.path).thenReturn(mockedFilePath);
        when(mockFile.existsSync()).thenReturn(true);
        when(mockFile.deleteSync()).thenAnswer((_) {
          deleteCount += 1;
        });
        when(mockedFileService.createFile(mockedFilePath)).thenReturn(mockFile);

        httpClientMocks
          ..response
              .setupStatusCode(mockedStatusCode)
              .setupContentLength(mockedData.length)
              .setupListen(mockedDataAsBytes,
                  onCreatedWhenExpectation: (expectation) {
            expectation.thenThrow('An error of some sort');
          });
        httpClientMocks.setup(mockedUrl);

        final service = DownloadService(
            httpClientMocks.httpClient, mockedFileService, MockLoggerService());
        expect(
          () async {
            try {
              await service.downloadFile(
                url: mockedUrl,
                filePath: mockedFilePath,
              );
            } catch (_) {
              rethrow;
            } finally {
              expect(deleteCount, greaterThan(0));
            }
          },
          throwsA(anything),
        );
      });
    });

    group('getData', () {
      group('getData', () {
        test('returns JSON string from URL', () async {
          final mockedData = {
            'property1': mockString(),
            'property2': mockString(),
          };
          final mockedJsonString = jsonEncode(mockedData);
          final mockedUrl = 'https://${mockString()}';
          final httpClientMocks = HttpClientMocks();

          httpClientMocks
            ..response
                .setupStatusCode(HttpStatus.ok)
                .setupContentLength(mockedData.length)
                .setupTransform(utf8.encode(mockedJsonString))
            ..setup(mockedUrl);

          final service = DownloadService(httpClientMocks.httpClient,
              MockFileService(), MockLoggerService());
          final jsonString = await service.getData(mockedUrl);

          expect(jsonString, isNotNull);
          expect(jsonString, equals(mockedJsonString));
        });
      });
    });
  });
}
