import 'dart:async';

import 'package:save_gfy/models/download_info.dart';
import 'package:save_gfy/values/source_metadata.dart';

abstract class SourceService {
  final String name = 'Source';

  bool isValidSource(String url);

  Future<String> formatUrl(String url);

  Future<SourceMetadata> queryDownloads(String currentUrl);

  Future download(String downloadsPath, DownloadInfo downloadInfo,
      SourceMetadata metadata, void Function(int, int) onDownloadProgress,
      {void Function(StreamSubscription) onDownloadStarted});
}
