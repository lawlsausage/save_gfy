import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:save_gfy/features/web_view/web_view_bloc.dart';
import 'package:save_gfy/features/web_view/web_view_controller.dart';
import 'package:save_gfy/services/logger_service.dart';

typedef void WebViewCreatedCallback(WebViewBloc bloc);
typedef void WebViewProgressChangedCallback(int progress);

class WebView extends StatefulWidget {
  WebView({
    Key key,
    this.onWebViewCreated,
    this.onWebViewProgressChanged,
  }) : super(key: key);

  final WebViewCreatedCallback onWebViewCreated;

  final WebViewProgressChangedCallback onWebViewProgressChanged;

  @override
  State<StatefulWidget> createState() => WebViewState();
}

class WebViewState extends State<WebView> {
  final WebViewBloc webViewBloc = WebViewBloc();

  Map<TargetPlatform, Widget Function()> _viewStrategy;

  LoggerService loggerService;

  void _onPlatformViewCreated(int id) {
    final controller = WebViewController(
      id: id,
      loggerService: loggerService,
      onWebViewProgressChanged: widget.onWebViewProgressChanged,
    );
    webViewBloc.updateWebViewController(controller);
    widget.onWebViewCreated?.call(webViewBloc);
  }

  Widget _createAndroidView() {
    return Container(
      child: AndroidView(
        viewType: 'webview',
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
  }

  @override
  void initState() {
    super.initState();

    _viewStrategy =
        Map.unmodifiable({TargetPlatform.android: _createAndroidView});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    loggerService = Provider.of<LoggerService>(context);
  }

  @override
  Widget build(BuildContext context) {
    final widget = _viewStrategy.containsKey(defaultTargetPlatform)
        ? _viewStrategy[defaultTargetPlatform]()
        : Text(
            '$defaultTargetPlatform is not yet supported by the web view plugin');
    // if (defaultTargetPlatform == TargetPlatform.android) {
    //   return AndroidView(
    //     viewType: 'webview',
    //     onPlatformViewCreated: _onPlatformViewCreated,
    //   );
    // }
    // // TODO add other platforms
    // return Text(
    //     '$defaultTargetPlatform is not yet supported by the map view plugin');
    return widget;
  }

  @override
  void dispose() {
    super.dispose();
    webViewBloc.dispose();
    loggerService.d('Disposed web view');
  }
}
