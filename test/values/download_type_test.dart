import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:save_gfy/values/download_type.dart';

import '../config.dart';

void main() {
  configureEnvironment();
  
  group('DownloadType', () {
    test('DownloadType.mp4.name returns mp4 String', () {
      expect(DownloadType.mp4.name, equals('mp4'));
    });

    test('DownloadType.webm.name returns webm String', () {
      expect(DownloadType.webm.name, equals('webm'));
    });

    test('DownloadType.unknown.name returns unknown String', () {
      expect(DownloadType.unknown.name, equals('unknown'));
    });
  });

  group('downloadTypeFromMimeType', () {
    test('video/mp4 mime type returns DownloadType.mp4', () {
      expect(downloadTypeFromMimeType('video/mp4'), equals(DownloadType.mp4));
    });

    test('video/webm mime type returns DownloadType.webm', () {
      expect(downloadTypeFromMimeType('video/webm'), equals(DownloadType.webm));
    });

    test('null mimeType parameters returns DownloadType.unknown', () {
      expect(downloadTypeFromMimeType(null), equals(DownloadType.unknown));
    });

    test('not implemented mime type returns DownloadType.unknown', () {
      expect(
          downloadTypeFromMimeType(mockString()), equals(DownloadType.unknown));
    });
  });
}
