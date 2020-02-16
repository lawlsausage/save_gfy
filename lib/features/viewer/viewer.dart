import 'dart:async';

import 'package:flutter/material.dart';
import 'package:save_gfy/features/buttons/hidable_fab.dart';
import 'package:save_gfy/features/download/download_dialog.dart';
import 'package:save_gfy/features/download/download_options.dart';
import 'package:save_gfy/features/progress_indicators/self_visible_linear_progress_indicator.dart';
import 'package:save_gfy/features/viewer/viewer_bloc.dart';
import 'package:save_gfy/features/web_view/web_view.dart';
import 'package:save_gfy/services/logger_service.dart';
import 'package:save_gfy/services/source_service.dart';
import 'package:save_gfy/values/download_info.dart';
import 'package:save_gfy/values/source_metadata.dart';

class Viewer extends StatefulWidget {
  Viewer({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  _ViewerState createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ViewerBloc _viewerBloc = ViewerBloc();

  void _handleViewDownloads() async {
    try {
      final timeoutDuration = Duration(seconds: 3);
      final loadingSnackbarController = _showSnackBar(
        content: Row(children: [
          CircularProgressIndicator(),
          Container(
            padding: EdgeInsets.only(left: kTabLabelPadding.left),
            child: Text('Loading...'),
          ),
        ]),
        duration: timeoutDuration,
      );
      final timeout = Timer(timeoutDuration, () {
        throw 'Retrieving available downloads timed out.';
      });
      final sourceService = _viewerBloc.getSourceService();
      final sourceMetadata = await _viewerBloc.queryDownloads();
      timeout.cancel();
      loadingSnackbarController.close();
      if ((sourceMetadata?.downloads?.length ?? 0) > 0) {
        _showDownloadsModal(sourceMetadata, sourceService);
      }
    } catch (err) {
      final message = err is String ? err : 'Unable to retrieve downloads.';
      _showSnackBar(message: message);
    }
  }

  void _downloadSelected(DownloadInfo downloadInfo,
      SourceMetadata sourceMetadata, SourceService sourceService) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DownloadDialog(
          onDownloadProgressCallback: _handleDownloadProgress,
          downloadsPath: _viewerBloc.downloadsPath,
          downloadInfo: downloadInfo,
          sourceMetadata: sourceMetadata,
          sourceService: sourceService,
        );
      },
      barrierDismissible: false,
    );
  }

  void _handleDownloadProgress(int received, int total) {
    final newStatus =
        received != total ? ViewerStatus.downloadingFile : ViewerStatus.idle;
    _viewerBloc.updateStatus(newStatus);
  }

  void _showDownloadsModal(
      SourceMetadata metadata, SourceService sourceService) {
    final handleTap = (BuildContext context, DownloadInfo downloadInfo) async {
      await Future.delayed(const Duration(milliseconds: 100));
      Navigator.pop(context);
      _downloadSelected(downloadInfo, metadata, sourceService);
    };

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DownloadOptions(
          downloadName: metadata.name,
          downloads: metadata.downloads,
          onTapDownloadOption: (downloadInfo) =>
              handleTap(context, downloadInfo),
        );
      },
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar({
    String message,
    Widget content,
    Duration duration,
  }) {
    final snackBar = SnackBar(
      content: content != null ? content : Text(message),
    );
    return _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: _viewerBloc.getProgress,
            initialData: 100.0,
            builder: (context, AsyncSnapshot<double> snapshot) =>
                SelfVisibleLinearProgressIndicator(
              value: snapshot.data / 100,
              semanticsLabel: 'Web View Progress',
            ),
          ),
          Expanded(
            child: Center(
              child: StreamBuilder(
                stream: _viewerBloc.isVisible,
                initialData: false,
                builder: (context, AsyncSnapshot<bool> snapshot) => Visibility(
                  visible: snapshot.data,
                  child: WebView(
                    onWebViewCreated: _viewerBloc.handleWebViewCreated,
                    onWebViewProgressChanged: (progress) => _viewerBloc
                        .webViewBloc?.updateProgress
                        ?.call(progress.toDouble()),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder(
        stream: _viewerBloc.getStatus,
        initialData: ViewerStatus.loadingPage,
        builder: (context, AsyncSnapshot<ViewerStatus> snapshot) => HidableFab(
          onPressed: _handleViewDownloads,
          hide: snapshot.data != ViewerStatus.idle,
          tooltip: 'View Available Downloads',
          fabChild: Icon(Icons.file_download),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _viewerBloc.dispose();
    loggerService.d('Disposed viewer');
  }
}
