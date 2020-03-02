import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/download_service.dart';

class MockStreamSubscription extends Mock implements StreamSubscription {}

class MockDownloadService extends Mock implements DownloadService {
  MockDownloadService setupDownloadFile({
    String url,
    String downloadsPath,
    String path,
    String Function(Invocation) onAnswer,
  }) {
    when(this.downloadFile(
      url: argThat(equals(url), named: 'url'),
      filePath: argThat(stringContainsInOrder([downloadsPath, path]),
          named: 'filePath'),
      onDownloadProgress: anyNamed('onDownloadProgress'),
      onDownloadStarted: anyNamed('onDownloadStarted'),
    )).thenAnswer((invocation) {
      final void Function(int, int) onDownloadProgress =
          invocation.namedArguments[#onDownloadProgress];
      final void Function(StreamSubscription, int) onDownloadStarted =
          invocation.namedArguments[#onDownloadStarted];
      final answer = onAnswer?.call(invocation) ?? mockString();
      onDownloadProgress?.call(0, 0);
      onDownloadStarted?.call(MockStreamSubscription(), mockInteger());
      return Future.value(answer);
    });
    return this;
  }
}
