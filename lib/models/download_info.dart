import 'package:save_gfy/values/download_type.dart';

class DownloadInfo {
  DownloadInfo({
    this.type,
    this.name,
    this.url,
    this.quality,
  });

  DownloadType type;

  String name;

  String url;

  String quality;
}