import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/source_service.dart';
import 'package:save_gfy/values/download_info.dart';
import 'package:save_gfy/values/source_metadata.dart';

import '../config.dart';

class TesterSourceService extends SourceService {
  TesterSourceService(this._hosts);

  final List<String> _hosts;

  @override
  List<String> get hosts => _hosts;

  @override
  Future download(String downloadsPath, DownloadInfo downloadInfo, SourceMetadata metadata, void Function(int, int) onDownloadProgress, {void Function(StreamSubscription) onDownloadStarted}) {
    return null;
  }

  @override
  Future<String> formatUrl(String url) {
    return null;
  }

  @override
  Future<SourceMetadata> queryDownloads(String currentUrl) {
    return null;
  }
}

void main() {
  configureEnvironment();

  group('SourceService', () {
    group('isValidSource', () {
      test('returns true for matching host in URL', () {
        final mockedHosts = mockRange<String>(mockString, mockInteger(1, 5), include: 'a#');
        final service = TesterSourceService(mockedHosts);
        final hostIndex =
            mockedHosts.length > 1 ? mockInteger(0, mockedHosts.length - 1) : 0;
        final mockedUrl = 'https://${mockedHosts[hostIndex]}/${mockString()}';

        expect(service.isValidSource(mockedUrl), isTrue);
      });

      test('returns false for URL with non-matching host', () {
        final mockedHosts = mockRange<String>(mockString, mockInteger(1, 5), include: 'a#');
        final service = TesterSourceService(mockedHosts);
        final mockedUrl = 'https://${mockString()}/${mockString()}';

        expect(service.isValidSource(mockedUrl), isFalse);
      });
    });
  });
}
