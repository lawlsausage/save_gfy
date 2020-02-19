import 'dart:async';

import 'package:flutter/material.dart';
import 'package:save_gfy/features/download/download_bloc.dart';
import 'package:save_gfy/main.dart';
import 'package:save_gfy/models/download_info.dart';
import 'package:save_gfy/services/download_service.dart';
import 'package:save_gfy/services/logger_service.dart';
import 'package:save_gfy/services/source_service.dart';
import 'package:save_gfy/values/download_progress_metadata.dart';
import 'package:save_gfy/values/source_metadata.dart';

class DownloadDialog extends StatefulWidget {
  DownloadDialog({
    Key key,
    this.onDownloadProgressCallback,
    this.downloadsPath,
    this.downloadInfo,
    this.sourceMetadata,
    this.sourceService,
  }) : super(key: key);

  final OnDownloadProgressCallback onDownloadProgressCallback;

  final String downloadsPath;

  final DownloadInfo downloadInfo;

  final SourceMetadata sourceMetadata;

  final SourceService sourceService;

  @override
  DownloadDialogState createState() => DownloadDialogState();
}

class DownloadDialogState extends State<DownloadDialog>
    with SingleTickerProviderStateMixin {
  StreamSubscription _subscription;
  DownloadBloc _downloadBloc = DownloadBloc();

  @override
  void initState() {
    super.initState();

    _downloadFile();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Downloading'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StreamBuilder(
            stream: _downloadBloc.getProgressMetadata,
            builder:
                (context, AsyncSnapshot<DownloadProgressMetadata> snapshot) {
              return Text(
                '${snapshot.data?.received ?? 0} out of ${snapshot.data?.total ?? 0} bytes',
              );
            },
          ),
          StreamBuilder(
            stream: _downloadBloc.getProgress,
            builder: (context, AsyncSnapshot<double> snapshot) {
              return LinearProgressIndicator(
                semanticsLabel: 'Download Progress',
                value: snapshot.data,
              );
            },
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () => _handleCancelPressed(context),
        ),
      ],
    );
  }

  void _handleDownloadStarted(StreamSubscription subscription) {
    _subscription = subscription;
  }

  void _handleCancelPressed(BuildContext context) {
    _subscription.cancel();
    Navigator.of(context).pop();
  }

  Future _downloadFile() async {
    try {
      await widget.sourceService?.download(widget.downloadsPath,
          widget.downloadInfo, widget.sourceMetadata, _downloadBloc.update,
          onDownloadStarted: _handleDownloadStarted);

      Timer(Duration(milliseconds: 1000), () {
        Navigator.of(context).pop();
      });
      Timer(Duration(milliseconds: 1500), () {
        MyApp.platform.invokeMethod('openDirectory');
      });
    } catch (err) {
      loggerService.d('Download error occurred.', err);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _downloadBloc.dispose();
    loggerService.d('DownloadDialog disposed');
  }
}
