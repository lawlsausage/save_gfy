import 'package:save_gfy/values/download_type.dart';

class DownloadInfo {
  DownloadInfo({
    this.type,
    this.name,
    this.url,
    this.quality,
  });

  final DownloadType type;

  final String name;

  final String url;

  final String quality;
}