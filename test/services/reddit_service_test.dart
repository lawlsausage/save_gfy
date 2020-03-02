import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/logger_service.dart';
import 'package:save_gfy/services/reddit_service.dart';
import 'package:save_gfy/services/video_service.dart';
import 'package:save_gfy/values/download_info.dart';
import 'package:save_gfy/values/source_metadata.dart';

import '../config.dart';
import '../mocks/config_service_mocks.dart';
import '../mocks/mock_download_service.dart';
import '../mocks/mock_file_service.dart';

class MockDownloadInfo extends Mock implements DownloadInfo {}

class MockSourceMetadata extends Mock implements SourceMetadata {}

class MockVideoService extends Mock implements VideoService {}

class MockLoggerService extends Mock implements LoggerService {}

class RedditServiceMocks {
  final configServiceMocks = _setupConfigServiceMocks();
  final mockedPath = mockString();
  final mockedDownloadsPath = '${mockString()}/${mockString()}';
  final mockDownloadService = MockDownloadService();
  final mockDownloadInfo = MockDownloadInfo();
  final mockSourceMetadata = MockSourceMetadata();
  final mockFileService = MockFileService(
      mockFileFactory: (filePath) => MockFile(filePath: filePath));
  final mockVideoService = MockVideoService();

  String get mockedUrl => 'https://v.redd.it/$mockedPath/DASH_96.mp4';
  String get mockedAudioUrl => 'https://v.redd.it/$mockedPath/audio';
}

ConfigServiceMocks _setupConfigServiceMocks({List<String> hosts}) {
  return ConfigServiceMocks()
    ..mockAppConfig.setupRedditAppSiteConfig(
      onSetupAppSiteConfig: (mockAppSiteConfig) {
        mockAppSiteConfig.setupHosts(hosts);
        return mockAppSiteConfig;
      },
    )
    ..setup();
}

List<List<int>> _mockHeightAndWidths(
  int count, {
  List<List<int>> heightAndWidths,
}) {
  List<List<int>> result = heightAndWidths ?? [];

  if (count == 0) {
    return result;
  }
  final height =
      result.isNotEmpty ? result.last[0] + 100 : mockInteger(50, 100);
  final width = (height * 1.75).toInt();

  result.add([height, width]);

  return _mockHeightAndWidths(count - 1, heightAndWidths: result);
}

String _mockRepresentationXmlString(int height, int width) {
  return '            <Representation bandwidth="${mockInteger(1, 100000)}" codecs="avc1.4d401e" frameRate="30" height="$height" id="VIDEO-1" mimeType="video/mp4" startWithSAP="1" width="$width">'
      '                <BaseURL>DASH_$height</BaseURL>'
      '                <SegmentBase indexRange="918-997" indexRangeExact="true">'
      '                    <Initialization range="0-917"/>'
      '                </SegmentBase>'
      '            </Representation>';
}

String _mockDashPlaylistXml(String representationXmlString) {
  return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<MPD mediaPresentationDuration="PT13.5S" minBufferTime="PT1.500S" profiles="urn:mpeg:dash:profile:isoff-on-demand:2011" type="static" xmlns="urn:mpeg:dash:schema:mpd:2011">'
      '    <Period duration="PT13.5S">'
      '        <AdaptationSet segmentAlignment="true" subsegmentAlignment="true" subsegmentStartsWithSAP="1">'
      '$representationXmlString'
      '        </AdaptationSet>'
      '    </Period>'
      '</MPD>';
}

Future _testDownload(
  void Function(
          RedditServiceMocks mocks, MockDownloadService mockDownloadService)
      onSetupDownloadService, {
  void Function(int received, int totalBytes) onDownloadProgress,
  void Function(StreamSubscription subscription) onDownloadStarted,
  int Function(Invocation invocation) onMergeVideoAndAudioAnswer,
}) async {
  final configServiceMocks = _setupConfigServiceMocks();
  final redditServiceMocks = RedditServiceMocks();

  when(redditServiceMocks.mockDownloadInfo.url)
      .thenReturn(redditServiceMocks.mockedUrl);
  when(redditServiceMocks.mockDownloadInfo.name)
      .thenReturn(redditServiceMocks.mockedPath);
  onSetupDownloadService(
      redditServiceMocks, redditServiceMocks.mockDownloadService);
  when(redditServiceMocks.mockVideoService.mergeVideoAndAudio(
    argThat(anything),
    argThat(anything),
    argThat(anything),
  )).thenAnswer((invocation) {
    final result = onMergeVideoAndAudioAnswer?.call(invocation) ?? 0;
    return Future.value(result);
  });

  final service = RedditService(
    configServiceMocks.mockConfigService,
    redditServiceMocks.mockDownloadService,
    redditServiceMocks.mockFileService,
    redditServiceMocks.mockVideoService,
    MockLoggerService(),
  );
  await service.download(
    redditServiceMocks.mockedDownloadsPath,
    redditServiceMocks.mockDownloadInfo,
    redditServiceMocks.mockSourceMetadata,
    onDownloadProgress,
    onDownloadStarted: onDownloadStarted,
  );
}

void main() {
  configureEnvironment();

  group('RedditService', () {
    group('properties', () {
      test('name returns Reddit', () {
        final configMocks = _setupConfigServiceMocks();
        final service = RedditService(
          configMocks.mockConfigService,
          MockDownloadService(),
          MockFileService(),
          MockVideoService(),
          MockLoggerService(),
        );

        expect(service.name, equals('Reddit'));
      });
    });

    group('queryDownloads', () {
      test('successfully queries from https://reddit.com URL', () async {
        final configServiceMocks = _setupConfigServiceMocks();
        final mockedUrl = 'https://reddit.com/${mockString()}/${mockString()}';
        final mockedDownloadService = MockDownloadService();
        final mockedVideoId = mockString();
        final mockedDashPlaylistUrl =
            'https://v.redd.it/$mockedVideoId/DASHPlaylist.mpd';
        final mockedMetadataJson = [
          {
            'data': {
              'children': [
                {
                  'data': {
                    'secure_media': {
                      'reddit_video': {
                        'fallback_url':
                            'https://v.redd.it/$mockedVideoId/DASH_96.mp4',
                        'dash_url': mockedDashPlaylistUrl,
                      },
                    },
                  },
                },
              ],
            },
          },
        ];
        final mockedHeightAndWidths = _mockHeightAndWidths(mockInteger(1, 5));
        final mockedRepresentationXmlString = mockedHeightAndWidths
            .map((heightAndWidth) => _mockRepresentationXmlString(
                heightAndWidth[0], heightAndWidth[1]))
            .join('\n');
        final mockedDashPlaylistXmlString =
            _mockDashPlaylistXml(mockedRepresentationXmlString);

        when(mockedDownloadService.getData(argThat(equals('$mockedUrl/.json'))))
            .thenAnswer((_) => Future.value(jsonEncode(mockedMetadataJson)));
        when(mockedDownloadService
                .getData(argThat(equals(mockedDashPlaylistUrl))))
            .thenAnswer((_) => Future.value(mockedDashPlaylistXmlString));

        final service = RedditService(
          configServiceMocks.mockConfigService,
          mockedDownloadService,
          MockFileService(),
          MockVideoService(),
          MockLoggerService(),
        );
        final metadata = await service.queryDownloads(mockedUrl);

        expect(metadata, isNotNull);
        expect(metadata.name, equals(mockedVideoId));
        expect(metadata.sourceUrl, equals(mockedUrl));
        expect(metadata.downloads, hasLength(mockedHeightAndWidths.length));

        metadata.downloads.asMap().forEach((index, value) {
          final heightAndWidth = mockedHeightAndWidths[index];
          final width = heightAndWidth[1];

          expect(value.name, stringContainsInOrder([mockedVideoId, '$width']));
        });
      });

      test('successfully queries from https://v.redd.it URL', () async {
        final configServiceMocks = _setupConfigServiceMocks();
        final mockedDownloadService = MockDownloadService();
        final mockedVideoId = mockString();
        final mockedUrl = 'https://v.redd.it/$mockedVideoId/DASHPlaylist.mpd';
        final mockedHeightAndWidths = _mockHeightAndWidths(mockInteger(1, 5));
        final mockedRepresentationXmlString = mockedHeightAndWidths
            .map((heightAndWidth) => _mockRepresentationXmlString(
                heightAndWidth[0], heightAndWidth[1]))
            .join('\n');
        final mockedDashPlaylistXmlString =
            _mockDashPlaylistXml(mockedRepresentationXmlString);

        when(mockedDownloadService.getData(argThat(equals(mockedUrl))))
            .thenAnswer((_) => Future.value(mockedDashPlaylistXmlString));

        final service = RedditService(
          configServiceMocks.mockConfigService,
          mockedDownloadService,
          MockFileService(),
          MockVideoService(),
          MockLoggerService(),
        );
        final metadata = await service.queryDownloads(mockedUrl);

        expect(metadata, isNotNull);
        expect(metadata.name, equals(mockedVideoId));
        expect(metadata.sourceUrl, equals(mockedUrl));
        expect(metadata.downloads, hasLength(mockedHeightAndWidths.length));

        metadata.downloads.asMap().forEach((index, value) {
          final heightAndWidth = mockedHeightAndWidths[index];
          final width = heightAndWidth[1];

          expect(value.name, stringContainsInOrder([mockedVideoId, '$width']));
        });
      });

      test('rethrows error when parsing Reddit JSON', () async {
        final configServiceMocks = _setupConfigServiceMocks();
        final mockedUrl = 'https://reddit.com/${mockString()}/${mockString()}';
        final mockedDownloadService = MockDownloadService();
        final mockedMetadataJson = List<dynamic>();

        when(mockedDownloadService.getData(argThat(equals('$mockedUrl/.json'))))
            .thenAnswer((_) => Future.value(jsonEncode(mockedMetadataJson)));

        final service = RedditService(
          configServiceMocks.mockConfigService,
          mockedDownloadService,
          MockFileService(),
          MockVideoService(),
          MockLoggerService(),
        );

        expect(() async => await service.queryDownloads(mockedUrl),
            throwsA(anything));
      });

      test('rethrows error when parsing DASHPlaylist XML', () async {
        final configServiceMocks = _setupConfigServiceMocks();
        final mockedDownloadService = MockDownloadService();
        final mockedVideoId = mockString();
        final mockedUrl = 'https://v.redd.it/$mockedVideoId/DASHPlaylist.mpd';

        when(mockedDownloadService.getData(argThat(equals(mockedUrl))))
            .thenAnswer((_) => Future.value(''));

        final service = RedditService(
          configServiceMocks.mockConfigService,
          mockedDownloadService,
          MockFileService(),
          MockVideoService(),
          MockLoggerService(),
        );

        expect(() async => await service.queryDownloads(mockedUrl),
            throwsA(anything));
      });
    });

    group('download', () {
      test('successfully completes download even with not found audio file',
          () async {
        var downloadFileRequestCount = 0;
        var downloadProgressCount = 0;
        var downloadStartedCount = 0;
        var isVideoAndAudioMerged = false;

        void handleDownloadProgress(int received, int totalBytes) {
          downloadProgressCount += 1;
          expect(received, equals(0));
          expect(totalBytes, equals(0));
        }

        void handleDownloadStarted(StreamSubscription subscription) {
          downloadStartedCount += 1;
          expect(subscription, isNotNull);
        }

        await _testDownload(
            (mocks, mockDownloadService) {
              mockDownloadService
                  .setupDownloadFile(
                    url: mocks.mockedUrl,
                    downloadsPath: mocks.mockedDownloadsPath,
                    path: mocks.mockedPath,
                    onAnswer: (_) {
                      downloadFileRequestCount += 1;
                      return mockString();
                    },
                  )
                  .setupDownloadFile(
                    url: mocks.mockedAudioUrl,
                    downloadsPath: mocks.mockedDownloadsPath,
                    path: mocks.mockedPath,
                    onAnswer: (_) {
                      downloadFileRequestCount += 1;
                      return mockString();
                    },
                  );
            },
            onDownloadProgress: handleDownloadProgress,
            onDownloadStarted: handleDownloadStarted,
            onMergeVideoAndAudioAnswer: (_) {
              isVideoAndAudioMerged = true;
              return 0;
            });

        expect(
          downloadFileRequestCount,
          equals(2),
          reason: 'Both video and audio files should be downloaded.',
        );
        expect(
          downloadProgressCount,
          equals(2),
          reason:
              'Both video and audio files download call onDownloadProgress.',
        );
        expect(
          downloadStartedCount,
          equals(2),
          reason: 'Both video and audio files call onDownloadStarted.',
        );
        expect(isVideoAndAudioMerged, isTrue);
      });

      test('successfully completes download of both video and audio', () async {
        var downloadFileRequestCount = 0;
        var downloadProgressCount = 0;
        var downloadStartedCount = 0;
        var isVideoAndAudioMerged = false;

        void handleDownloadProgress(int received, int totalBytes) {
          downloadProgressCount += 1;
          expect(received, equals(0));
          expect(totalBytes, equals(0));
        }

        void handleDownloadStarted(StreamSubscription subscription) {
          downloadStartedCount += 1;
          expect(subscription, isNotNull);
        }

        await _testDownload(
            (mocks, mockDownloadService) {
              mockDownloadService
                  .setupDownloadFile(
                    url: mocks.mockedUrl,
                    downloadsPath: mocks.mockedDownloadsPath,
                    path: mocks.mockedPath,
                    onAnswer: (_) {
                      downloadFileRequestCount += 1;
                      return mockString();
                    },
                  )
                  .setupDownloadFile(
                    url: mocks.mockedAudioUrl,
                    downloadsPath: mocks.mockedDownloadsPath,
                    path: mocks.mockedPath,
                    onAnswer: (_) {
                      downloadFileRequestCount += 1;
                      throw ('Some sort of error code like a 404');
                    },
                  );
            },
            onDownloadProgress: handleDownloadProgress,
            onDownloadStarted: handleDownloadStarted,
            onMergeVideoAndAudioAnswer: (_) {
              isVideoAndAudioMerged = true;
              return 0;
            });

        expect(
          downloadFileRequestCount,
          equals(2),
          reason: 'Both video and audio files should invoke download requests.',
        );
        expect(
          downloadProgressCount,
          equals(1),
          reason: 'Only video is available and calls onDownloadProgress.',
        );
        expect(
          downloadStartedCount,
          equals(1),
          reason: 'Only video is available and calls onDownloadStarted.',
        );
        expect(
          isVideoAndAudioMerged,
          isFalse,
          reason: 'No audio to merge with video.',
        );
      });
    });
  });
}
