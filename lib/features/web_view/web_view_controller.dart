import 'package:flutter/services.dart';
import 'package:save_gfy/features/web_view/web_view.dart';
import 'package:save_gfy/main.dart';
import 'package:save_gfy/services/logger_service.dart';

class WebViewController {
  WebViewController({
    int id,
    this.onWebViewProgressChanged,
  }) {
    _channel = new MethodChannel('$channelName/webview$id');
    _channel.setMethodCallHandler(_handleMethodCall);

    _methodCallStrategy = Map.unmodifiable({
      'onJavascriptResult': _handleJavascriptResult,
      'onPageFinished': _handlePageFinished,
      'onRedirect': _handleRedirect,
      'progressChanged': _handleProgressChanged
    });
  }

  final WebViewProgressChangedCallback onWebViewProgressChanged;

  MethodChannel _channel;

  Map<String, void Function(MethodCall call)> _methodCallStrategy;

  void Function(String) _javascriptResultHandler;

  void Function(String) _pageFinishedHandler;
  set pageFinishedHandler(void Function(String) handler) {
    _pageFinishedHandler = handler;
  }

  void Function(String) _pageRedirectedHandler;
  set pageRedirectedHandler(void Function(String) handler) {
    _pageRedirectedHandler = handler;
  }

  Future<void> loadUrl(String url) async {
    return _channel.invokeMethod('loadUrl', url);
  }

  Future<void> execJavascript(
      String script, void Function(String) handler) async {
    _javascriptResultHandler = handler;
    return _channel.invokeMethod('execJavascript', script);
  }

  void _handleJavascriptResult(MethodCall call) {
    final String result = call.arguments as String;
    if (_javascriptResultHandler != null) _javascriptResultHandler(result);
  }

  void _handlePageFinished(MethodCall call) {
    final String url = call.arguments as String;
    loggerService.d('finished loading $url');
    _pageFinishedHandler?.call(url);
  }

  void _handleRedirect(MethodCall call) {
    final String url = call.arguments as String;
    loggerService.d('redirect to $url');
    _pageRedirectedHandler?.call(url);
  }

  void _handleProgressChanged(MethodCall call) {
    final int progress = call.arguments as int;
    onWebViewProgressChanged?.call(progress);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    final handler = _methodCallStrategy[call.method];
    handler?.call(call);

    return Future.value('');
  }
}
