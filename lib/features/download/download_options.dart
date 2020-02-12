import 'package:flutter/material.dart';
import 'package:save_gfy/values/download_info.dart';

typedef void OnTapDownloadOption(DownloadInfo downloadInfo);

class DownloadOptions extends StatelessWidget {
  const DownloadOptions({
    Key key,
    this.onTapDownloadOption,
    this.downloadName,
    this.mp4Url,
    this.webmUrl,
    this.mobileUrl,
    this.downloads,
  }) : super(key: key);

  final OnTapDownloadOption onTapDownloadOption;

  final String downloadName;

  final String mp4Url;

  final String webmUrl;

  final String mobileUrl;
  
  final List<DownloadInfo> downloads;

  static const Map<DownloadType, String> _downloadNames = {
    DownloadType.mp4: '.mp4',
    DownloadType.webm: '.webm',
    DownloadType.mp4Mobile: 'mobile .mp4',
  };

  Iterable<ListTile> _buildOptions() {
    return downloads.map((download) => ListTile(
          title: Text(_downloadNames[download.type]),
          onTap: () => this.onTapDownloadOption(download),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Text('$downloadName Downloads'),
        ),
        Divider(
          height: 1,
        ),
      ]..addAll(_buildOptions()),
    );
  }
}
