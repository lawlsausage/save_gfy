import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:save_gfy/blocs/shared_url_bloc.dart';
import 'package:save_gfy/features/web_view/web_view_bloc.dart';
import 'package:save_gfy/main.dart';
import 'package:save_gfy/services/config_service.dart';
import 'package:save_gfy/services/download_service.dart';
import 'package:save_gfy/services/gfycat_service.dart';
import 'package:save_gfy/services/logger_service.dart';
import 'package:save_gfy/services/reddit_service.dart';
import 'package:save_gfy/services/source_service.dart';
import 'package:save_gfy/util/util.dart';
import 'package:save_gfy/values/source_metadata.dart';

enum ViewerStatus {
  idle,
  loadingPage,
  queryingDownloads,
  downloadingFile,
}

class ViewerBloc {
  ViewerBloc({this.context}) {
    configService = Provider.of<ConfigService>(context);
    downloadService = Provider.of<DownloadService>(context);
    _redditService = RedditService(configService, downloadService);

    isVisibleController.add(false);
    // Initializes the current URL with a default in case the no URL has been shared.
    currentUrlController.add(configService.appConfig.defaultUrl);

    initWebViewState();
    initDeviceContext();

    _sourceServices[_redditService.name] = _redditService;
  }

  final BuildContext context;

  final statusStreamController = BehaviorSubject<ViewerStatus>();
  Stream<ViewerStatus> get getStatus => statusStreamController.stream;

  final isVisibleController = BehaviorSubject<bool>();
  Stream<bool> get isVisible => isVisibleController.stream;

  final currentUrlController = BehaviorSubject<String>();
  Stream<String> get getCurrentUrl => currentUrlController.stream;

  final progressStreamController = BehaviorSubject<double>();
  Stream<double> get getProgress => progressStreamController.stream;

  final Map<String, SourceService> _sourceServices = {};

  ConfigService configService;

  DownloadService downloadService;

  WebViewBloc get webViewBloc => _webViewBloc;
  WebViewBloc _webViewBloc;

  SourceMetadata _sourceMetadata;

  String get downloadsPath => _downloadsPath;
  String _downloadsPath = '';

  GfycatService _gfycatService;

  RedditService _redditService;

  void initWebViewState() {
    Timer(Duration(milliseconds: 500), () {
      setVisible(true);
    });
  }

  void initDeviceContext() {
    Timer(Duration(milliseconds: 1000), () {
      MyApp.platform.invokeMethod('downloadsPath').then((path) {
        _downloadsPath = path;
        loggerService.d('Got downloadsPath: $downloadsPath');
      });
    });

    sharedUrlBloc.listen(_loadUrl);
  }

  void handleWebViewCreated(WebViewBloc bloc) {
    _webViewBloc = bloc;
    _webViewBloc.getProgress
        .listen((progress) => progressStreamController.sink.add(progress));
    _webViewBloc.getWebViewController.listen((controller) {
      controller.pageFinishedHandler = _handlePageFinished;
      controller.pageRedirectedHandler = _handlePageRedirected;
      _gfycatService = GfycatService(controller, configService, downloadService);
      _sourceServices[_gfycatService.name] = _gfycatService;

      // getCurrentUrl.listen((url) => controller.loadUrl(url));
      getCurrentUrl.listen((url) => _webViewBloc.updateCurrentUrl(url));
    });
    _webViewBloc.getProgress.listen(_handleProgress);
  }

  void updateStatus(ViewerStatus newStatus) {
    statusStreamController.sink.add(newStatus);
  }

  void updateCurrentUrl(String url) {
    currentUrlController.sink.add(url);
  }

  void setVisible(bool value) {
    isVisibleController.sink.add(value);
  }

  SourceService getSourceService({String url}) {
    final currentUrl = url ?? currentUrlController.value;
    return _sourceServices.values.firstWhere(
        (sourceService) => sourceService.isValidSource(currentUrl),
        orElse: () => null);
  }

  Future<SourceMetadata> queryDownloads() async {
    final currentUrl = currentUrlController.value;
    final sourceService = getSourceService();

    updateStatus(ViewerStatus.queryingDownloads);

    try {
      _sourceMetadata = _sourceMetadata == null
          ? await sourceService?.queryDownloads(currentUrl)
          : _sourceMetadata;
    } finally {
      updateStatus(ViewerStatus.idle);
    }

    return _sourceMetadata;
  }

  void _handlePageFinished(String url) {
    updateStatus(ViewerStatus.idle);
  }

  void _handlePageRedirected(String url) {
    updateCurrentUrl(url);
  }

  void _handleProgress(double progress) {
    final status =
        progress >= 100.0 ? ViewerStatus.idle : ViewerStatus.loadingPage;
    updateStatus(status);
  }

  Future _loadUrl(String url) async {
    final sourceService = getSourceService(url: url);
    final formattedUrl =
        Util.makeHttps((await sourceService?.formatUrl(url)) ?? url);
    _sourceMetadata = null;
    updateCurrentUrl(formattedUrl);
    updateStatus(ViewerStatus.loadingPage);
  }

  void dispose() {
    statusStreamController.close();
    isVisibleController.close();
    currentUrlController.close();
    progressStreamController.close();
  }
}
