import 'package:save_gfy/models/download_info.dart';

class SourceMetadata {
  SourceMetadata({
    this.downloads,
    this.sourceUrl,
    this.name,
  });

  List<DownloadInfo> downloads;

  String sourceUrl;

  String name;
}
