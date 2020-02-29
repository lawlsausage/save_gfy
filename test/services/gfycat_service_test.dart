import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/features/web_view/web_view_controller.dart';
import 'package:save_gfy/services/download_service.dart';
import 'package:save_gfy/services/gfycat_service.dart';
import 'package:save_gfy/values/download_info.dart';
import 'package:save_gfy/values/source_metadata.dart';

import '../config.dart';
import '../mocks/config_service_mocks.dart';

class MockWebViewController extends Mock implements WebViewController {}

class MockDownloadService extends Mock implements DownloadService {}

class MockDownloadInfo extends Mock implements DownloadInfo {}

class MockSourceMetadata extends Mock implements SourceMetadata {}

class MockStreamSubscription extends Mock implements StreamSubscription {}

ConfigServiceMocks _setupConfigServiceMocks({List<String> hosts}) {
  return ConfigServiceMocks()
    ..mockAppConfig.setupGfycatAppSiteConfig(
      onSetupAppSiteConfig: (mockAppSiteConfig) {
        mockAppSiteConfig.setupHosts(hosts);
        return mockAppSiteConfig;
      },
    )
    ..setup();
}

void main() {
  configureEnvironment();

  group('GfycatService', () {
    group('properties', () {
      test('name returns Gfycat', () {
        final configMocks = _setupConfigServiceMocks();
        final service = GfycatService(
          MockWebViewController(),
          configMocks.mockConfigService,
          MockDownloadService(),
        );

        expect(service.name, equals('Gfycat'));
      });
    });

    group('isValidSource', () {
      test('returns true for url which contains a valid host', () {
        final mockedHosts =
            mockRange<String>(mockString, mockInteger(2, 5), include: 'a#');
        final mockedHost = mockedHosts[mockInteger(0, mockedHosts.length - 1)];
        final mockedUrl = 'https://$mockedHost.com/hello-world';
        final configMocks = _setupConfigServiceMocks(hosts: mockedHosts);
        final service = GfycatService(
          MockWebViewController(),
          configMocks.mockConfigService,
          MockDownloadService(),
        );

        expect(service.isValidSource(mockedUrl), isTrue);
      });

      test('returns false for url which does not contain a valid host', () {
        final mockedHosts =
            mockRange<String>(mockString, mockInteger(1, 5), include: 'a#');
        final mockedHost = mockString(16, 'a#');
        final mockedUrl = 'https://$mockedHost.com/hello-world';
        final configMocks = _setupConfigServiceMocks(hosts: mockedHosts);
        final service = GfycatService(
          MockWebViewController(),
          configMocks.mockConfigService,
          MockDownloadService(),
        );

        expect(service.isValidSource(mockedUrl), isFalse);
      });
    });

    group('queryDownloads', () {
      test('successfully queries SourceMetadata', () async {
        final configServiceMocks = _setupConfigServiceMocks();
        final mockedJson = Map<String, dynamic>();
        for (var i = 0; i < mockInteger(1, 5); i += 1) {
          final mockedPath = mockString();
          mockedJson[mockedPath] = {
            'mp4Url': 'https://gfycat.com/$mockedPath.mp4',
            'webmUrl': 'https://gfycat.com/$mockedPath.webm',
            'mobileUrl': 'https://gfycat.com/$mockedPath-mobile.mp4',
          };
        }
        final randomKeyIndex = mockedJson.keys.length > 1
            ? mockInteger(0, mockedJson.keys.length - 1)
            : 0;
        final randomKey = mockedJson.keys.elementAt(randomKeyIndex);
        final mockedUrls = {
          'High': mockedJson[randomKey]['mp4Url'],
          'WEBM': mockedJson[randomKey]['webmUrl'],
          'Mobile': mockedJson[randomKey]['mobileUrl'],
        };
        final mockedUrl = 'https://gfycat.com/$randomKey';
        final mockWebViewController = MockWebViewController();

        when(mockWebViewController.execJavascript(
                argThat(equals('___INITIAL_STATE__.cache.gifs')), any))
            .thenAnswer((invocation) {
          final void Function(String) handler =
              invocation.positionalArguments[1];
          handler(jsonEncode(mockedJson));
          return Future.value();
        });

        final service = GfycatService(
          mockWebViewController,
          configServiceMocks.mockConfigService,
          MockDownloadService(),
        );
        final metadata = await service.queryDownloads(mockedUrl);

        expect(metadata, isNotNull);
        expect(metadata.name, contains(randomKey));
        expect(metadata.sourceUrl, equals(mockedUrl));
        expect(metadata.downloads, isNotEmpty);
        expect(metadata.downloads, hasLength(mockedUrls.keys.length));

        metadata.downloads.forEach((download) {
          final mockedUrl = mockedUrls[download.quality];

          expect(mockedUrl, isNotNull);
          expect(download.url, equals(mockedUrl));
        });
      });

      test('rethrows error from WebViewController', () async {
        final configServiceMocks = _setupConfigServiceMocks();
        final mockedUrl = 'https://gfycat.com/${mockString()}';
        final mockWebViewController = MockWebViewController();

        when(mockWebViewController.execJavascript(
                argThat(equals('___INITIAL_STATE__.cache.gifs')), any))
            .thenAnswer((_) => Future.error('A random error occurred!'));

        final service = GfycatService(
          mockWebViewController,
          configServiceMocks.mockConfigService,
          MockDownloadService(),
        );

        expect(
          () async => await service.queryDownloads(mockedUrl),
          throwsA(equals('A random error occurred!')),
        );
      });

      test('retrhows error when parsing Gfycat JSON', () async {
        final configServiceMocks = _setupConfigServiceMocks();
        final mockedUrl = 'https://gfycat.com/${mockString()}';
        final mockWebViewController = MockWebViewController();

        when(mockWebViewController.execJavascript(
                argThat(equals('___INITIAL_STATE__.cache.gifs')), any))
            .thenAnswer((invocation) {
          final void Function(String) handler =
              invocation.positionalArguments[1];
          handler(jsonEncode(Map<String, dynamic>()));
          return Future.value();
        });

        final service = GfycatService(
          mockWebViewController,
          configServiceMocks.mockConfigService,
          MockDownloadService(),
        );

        expect(
          () async => await service.queryDownloads(mockedUrl),
          throwsA(anything),
        );
      });
    });

    group('download', () {
      test('successfully completes download', () async {
        final configServiceMocks = _setupConfigServiceMocks();
        final mockedPath = mockString();
        final mockedUrl = 'https://gfycat.com/$mockedPath.mp4';
        final mockedDownloadsPath = '${mockString()}/${mockString()}/';
        final mockDownloadService = MockDownloadService();
        final mockDownloadInfo = MockDownloadInfo();
        final mockSourceMetadata = MockSourceMetadata();
        var downloadFileCount = 0;
        var downloadProgressCount = 0;
        var downloadStartedCount = 0;
        void handleDownloadProgress(int received, int totalBytes) {
          downloadProgressCount += 1;
          expect(received, equals(0));
          expect(totalBytes, equals(0));
        }

        void handleDownloadStarted(StreamSubscription subscription) {
          downloadStartedCount += 1;
          expect(subscription, isNotNull);
        }

        when(mockDownloadInfo.url).thenReturn(mockedUrl);
        when(mockDownloadService.downloadFile(
          url: argThat(
            equals(mockedUrl),
            named: 'url',
          ),
          filePath: argThat(
            stringContainsInOrder([mockedDownloadsPath, mockedPath]),
            named: 'filePath',
          ),
          onDownloadProgress: anyNamed('onDownloadProgress'),
          onDownloadStarted: anyNamed('onDownloadStarted'),
        )).thenAnswer((invocation) {
          final void Function(int, int) onDownloadProgress =
              invocation.namedArguments[#onDownloadProgress];
          final void Function(StreamSubscription, int) onDownloadStarted =
              invocation.namedArguments[#onDownloadStarted];
          downloadFileCount += 1;
          onDownloadProgress?.call(0, 0);
          onDownloadStarted?.call(MockStreamSubscription(), mockInteger());
          return Future.value(mockString());
        });

        final service = GfycatService(
          MockWebViewController(),
          configServiceMocks.mockConfigService,
          mockDownloadService,
        );
        await service.download(
          mockedDownloadsPath,
          mockDownloadInfo,
          mockSourceMetadata,
          handleDownloadProgress,
          onDownloadStarted: handleDownloadStarted,
        );

        expect(downloadFileCount, equals(1));
        expect(downloadProgressCount, equals(1));
        expect(downloadStartedCount, equals(1));
      });
    });
  });
}
