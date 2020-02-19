import 'dart:async';
import 'dart:convert';

import 'package:save_gfy/features/web_view/web_view_controller.dart';
import 'package:save_gfy/main.dart';
import 'package:save_gfy/models/download_info.dart';
import 'package:save_gfy/services/download_service.dart';
import 'package:save_gfy/services/source_service.dart';
import 'package:save_gfy/values/download_type.dart';
import 'package:save_gfy/values/source_metadata.dart';

class GfycatService implements SourceService {
  GfycatService(this.webViewController);

  final WebViewController webViewController;

  static const String _javascript = '___INITIAL_STATE__.cache.gifs';

  static const Map<DownloadType, String> _extensions = {
    DownloadType.mp4: '.mp4',
    DownloadType.webm: '.webm',
  };

  final List<String> _hosts = MyApp.configService.getAppConfig().gfycat.hosts;

  String _currentUrl;

  @override
  String get name => 'Gfycat';

  @override
  bool isValidSource(String url) {
    final formattedUrl = url?.toLowerCase() ?? '';
    final matchedHost = _hosts.firstWhere((host) => formattedUrl.contains(host),
        orElse: () => null);
    return matchedHost != null;
  }

  @override
  Future<String> formatUrl(String url) {
    return Future.value(url);
  }

  @override
  Future<SourceMetadata> queryDownloads(String currentUrl) {
    final completer = Completer<SourceMetadata>();
    _currentUrl = currentUrl;
    webViewController.execJavascript(_javascript, (result) {
      try {
        final downloadInfoList = _handleJavascriptResult(result);
        final type = downloadInfoList.first.type;
        final url = downloadInfoList.first.url;
        final name =
            url.substring(url.lastIndexOf('/'), url.indexOf(_extensions[type]));
        completer.complete(SourceMetadata(
            downloads: downloadInfoList, sourceUrl: currentUrl, name: name));
      } catch (err) {
        completer.completeError(err);
      }
    });
    return completer.future;
  }

  @override
  Future download(String downloadsPath, DownloadInfo downloadInfo,
      SourceMetadata metadata, void Function(int, int) onDownloadProgress,
      {void Function(StreamSubscription) onDownloadStarted}) async {
    final url = downloadInfo.url;
    final filePath = '$downloadsPath${url.substring(url.lastIndexOf("/"))}';
    await DownloadService.downloadFile(
        url: url,
        filePath: filePath,
        onDownloadProgress: onDownloadProgress,
        onDownloadStarted: (subscription, totalBytes) =>
            onDownloadStarted?.call(subscription));
  }

  List<DownloadInfo> _handleJavascriptResult(String result) {
    final json = jsonDecode(result);
    final handler = (json as Map<String, dynamic>).keys.isEmpty
        ? () => throw ('Gfycat downloads unavailable.')
        : () => _parseJson(json);
    return handler();
  }

  List<DownloadInfo> _parseJson(Map<String, dynamic> json) {
    final matchedKey = json.keys.firstWhere(
        (key) => _currentUrl.toLowerCase().contains(key.toLowerCase()));
    final gifInfo = json[matchedKey] as Map<String, dynamic>;
    final mp4Url = gifInfo['mp4Url'] as String;
    final webmUrl = gifInfo['webmUrl'] as String;
    final mobileUrl = gifInfo['mobileUrl'] as String;

    return [
      DownloadInfo(
          type: DownloadType.mp4,
          name: _parseDownloadName(mp4Url),
          url: mp4Url,
          quality: 'High'),
      DownloadInfo(
          type: DownloadType.webm,
          name: _parseDownloadName(webmUrl),
          url: webmUrl,
          quality: 'WEBM'),
      DownloadInfo(
          type: DownloadType.mp4,
          name: _parseDownloadName(mobileUrl),
          url: mobileUrl,
          quality: 'Mobile'),
    ];
  }

  String _parseDownloadName(String url) {
    return url.substring(url.lastIndexOf('/'));
  }
}
