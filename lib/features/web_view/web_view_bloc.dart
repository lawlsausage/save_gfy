import 'dart:async';

import 'package:rxdart/subjects.dart';
import 'package:save_gfy/features/web_view/web_view_controller.dart';

class WebViewBloc {
  WebViewBloc() {
    progressStreamController.add(100.0);
    getWebViewController.listen((controller) {
      _webViewController = controller;
    });
  }

  final progressStreamController = BehaviorSubject<double>();
  Stream<double> get getProgress => progressStreamController.stream;

  final currentUrlStreamController = BehaviorSubject<String>();
  Stream<String> get getCurrentUrl => currentUrlStreamController.stream;

  final webViewControllerStreamController =
      BehaviorSubject<WebViewController>();
  Stream<WebViewController> get getWebViewController =>
      webViewControllerStreamController.stream;

  WebViewController _webViewController;

  void updateProgress(double value) {
    double resolvedValue = value <= 100 ? value : 100.0;
    resolvedValue = value >= 0.0 ? value : 0.0;
    progressStreamController.sink.add(resolvedValue);
  }

  void updateCurrentUrl(String url) {
    currentUrlStreamController.sink.add(url);
    _webViewController.loadUrl(url);
  }

  void updateWebViewController(WebViewController controller) {
    webViewControllerStreamController.sink.add(controller);
    _webViewController = controller;
  }

  void dispose() {
    progressStreamController.close();
    currentUrlStreamController.close();
    webViewControllerStreamController.close();
  }
}
