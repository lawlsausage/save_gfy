import 'dart:async';

import 'package:save_gfy/values/download_info.dart';
import 'package:save_gfy/values/source_metadata.dart';

abstract class SourceService {
  final String name = 'Source';

  final List<String> hosts = [];

  bool isValidSource(String url) {
    final formattedUrl = url?.toLowerCase() ?? '';
    final matchedHost = hosts.firstWhere((host) => formattedUrl.contains(host),
        orElse: () => null);
    return matchedHost != null;
  }

  Future<String> formatUrl(String url);

  Future<SourceMetadata> queryDownloads(String currentUrl);

  Future download(String downloadsPath, DownloadInfo downloadInfo,
      SourceMetadata metadata, void Function(int, int) onDownloadProgress,
      {void Function(StreamSubscription) onDownloadStarted});
}
