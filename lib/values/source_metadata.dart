import 'package:save_gfy/values/download_info.dart';

class SourceMetadata {
  SourceMetadata({
    this.downloads,
    this.sourceUrl,
    this.name,
  });

  final List<DownloadInfo> downloads;

  final String sourceUrl;

  final String name;
}
