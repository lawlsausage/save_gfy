import 'package:flutter/material.dart';
import 'package:save_gfy/values/download_info.dart';

typedef void OnTapDownloadOption(DownloadInfo downloadInfo);

class DownloadOptions extends StatelessWidget {
  const DownloadOptions({
    Key key,
    this.onTapDownloadOption,
    this.downloadName,
    this.downloads,
  }) : super(key: key);

  final OnTapDownloadOption onTapDownloadOption;

  final String downloadName;

  final List<DownloadInfo> downloads;

  Iterable<ListTile> _buildOptions() {
    return downloads.map((download) {
      final quality =
          ((download.quality?.length ?? 0) > 0) ? '${download.quality} ' : '';
      return ListTile(
        title: Text('$quality${download.type}'),
        onTap: () => this.onTapDownloadOption(download),
      );
    });
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
