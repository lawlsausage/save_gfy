import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:save_gfy/main.dart';
import 'package:save_gfy/services/download_service.dart';
import 'package:save_gfy/services/source_service.dart';
import 'package:save_gfy/values/download_info.dart';
import 'package:save_gfy/values/source_metadata.dart';

class RedditService implements SourceService {
  static const String _redditVideoHostUrl = 'https://v.redd.it/';

  static const String _videoFileSuffix = '_savegfyorig';
  
  static const String _audioFileSuffix = '_savegfyorig_audio';

  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  final List<String> _hosts = MyApp.configService.getAppConfig().reddit.hosts;

  String _currentUrl;

  @override
  String get name => 'Reddit';

  @override
  bool isValidSource(String url) {
    final formattedUrl = url?.toLowerCase() ?? '';
    final matchedHost = _hosts.firstWhere((host) => formattedUrl.contains(host),
        orElse: () => null);
    return matchedHost != null;
  }

  @override
  Future<String> formatUrl(String url) {
    return Future.value(url.toLowerCase().contains('dashplaylist.mpd')
        ? url.substring(0, url.toLowerCase().indexOf('/dashplaylist.mpd'))
        : url);
  }

  @override
  Future<SourceMetadata> queryDownloads(String currentUrl) async {
    _currentUrl = currentUrl;
    final downloads = (await _getRedditDownload(_currentUrl)) ??
        _getVDotReddDotItDownload(_currentUrl);

    return SourceMetadata(
      name: ((downloads?.length ?? 0) > 0)
          ? _parseDownloadName(downloads[0].url)
          : '',
      downloads: downloads,
      sourceUrl: _currentUrl,
    );
  }

  @override
  Future download(String downloadsPath, DownloadInfo downloadInfo,
      SourceMetadata metadata, void Function(int, int) onDownloadProgress,
      {void Function(StreamSubscription) onDownloadStarted}) async {
    final downloadUrl = downloadInfo.url;
    final audioUrl =
        downloadUrl.substring(0, downloadUrl.indexOf('DASH')) + 'audio';

    int videoTotalBytes = 0;
    int videoReceivedBytes = 0;
    int audioTotalBytes = 0;
    int audioReceivedBytes = 0;

    final handleVideoDownloadProgress = (int receivedBytes, int totalBytes) {
      videoTotalBytes = totalBytes;
      videoReceivedBytes = receivedBytes;
      onDownloadProgress(videoReceivedBytes + audioReceivedBytes,
          videoTotalBytes + audioTotalBytes);
    };

    final handleAudioDownloadProgress = (int receivedBytes, int totalBytes) {
      audioTotalBytes = totalBytes;
      audioReceivedBytes = receivedBytes;
      onDownloadProgress(videoReceivedBytes + audioReceivedBytes,
          videoTotalBytes + audioTotalBytes);
    };

    final videoFilePath = await _downloadVideo(
        downloadsPath, downloadUrl, downloadInfo, handleVideoDownloadProgress,
        onDownloadStarted: onDownloadStarted);
    final audioFilePath = await _downloadAudio(
        downloadsPath, audioUrl, downloadInfo, handleAudioDownloadProgress,
        onDownloadStarted: onDownloadStarted);
    final filePaths = [videoFilePath];
    if (audioFilePath?.isNotEmpty ?? false) {
      filePaths.add(audioFilePath);
    }

    await _mergeFiles(filePaths);
  }

  Future<String> _downloadVideo(String downloadsPath, String url,
      DownloadInfo downloadInfo, void Function(int, int) onDownloadProgress,
      {void Function(StreamSubscription) onDownloadStarted}) async {
    final filePath = '$downloadsPath/${downloadInfo.name}';
    try {
      await DownloadService.downloadFile(
          url: url,
          filePath: filePath,
          onDownloadProgress: onDownloadProgress,
          onDownloadStarted: (subscription, totalBytes) =>
              onDownloadStarted?.call(subscription));
      return filePath;
    } catch (err) {
      return null;
    }
  }

  Future<String> _downloadAudio(String downloadsPath, String url,
      DownloadInfo downloadInfo, void Function(int, int) onDownloadProgress,
      {void Function(StreamSubscription) onDownloadStarted}) async {
    try {
      final name =
          downloadInfo.name.replaceAll(_videoFileSuffix, _audioFileSuffix);
      final filePath = '$downloadsPath/$name';
      await DownloadService.downloadFile(
          url: url,
          filePath: filePath,
          onDownloadProgress: onDownloadProgress,
          onDownloadStarted: (subscription, totalBytes) =>
              onDownloadStarted?.call(subscription));
      return filePath;
    } catch (err) {
      return null;
    }
  }

  Future _mergeFiles(List<String> filePaths) async {
    final outputFilePath = filePaths[0].replaceAll(_videoFileSuffix, '');
    if ((filePaths?.length ?? 0) > 1) {
      final returnCode = await _flutterFFmpeg.execute(
          '-i ${filePaths[0]} -i ${filePaths[1]} -c:v copy -c:a aac -strict experimental $outputFilePath');

      if (returnCode == 0) {
        File(filePaths[0]).delete();
        File(filePaths[1]).delete();
      }
    } else {
      File(filePaths[0]).renameSync(outputFilePath);
    }
  }

  Future<List<DownloadInfo>> _getRedditDownload(String url) async {
    if (!(url?.toLowerCase()?.contains('reddit') ?? false)) {
      return null;
    }

    final formattedUrl = _formatUrl(url);
    final jsonString = await DownloadService.getData(formattedUrl);
    final json = jsonDecode(jsonString);
    return _parseJson(json);
  }

  List<DownloadInfo> _getVDotReddDotItDownload(String url) {
    if (!(url?.toLowerCase()?.contains('v.redd.it') ?? false)) {
      return null;
    }

    return [
      DownloadInfo(
          type: DownloadType.mp4,
          name: '${_parseDownloadName(url)}$_videoFileSuffix.mp4',
          url: url),
    ];
  }

  String _formatUrl(String url) {
    String formattedUrl = url;
    if (!formattedUrl.endsWith('/')) {
      formattedUrl += '/';
    }
    return formattedUrl + '.json';
  }

  List<DownloadInfo> _parseJson(dynamic json) {
    final rootListings = json as List<dynamic>;
    final firstListing = rootListings.first as Map<String, dynamic>;
    final data = firstListing['data'];
    final children = data['children'] as List<dynamic>;
    final firstChild = children.first as Map<String, dynamic>;
    final firstChildData =
        firstChild['data'] as Map<String, dynamic> ?? const {};
    final secureMedia =
        firstChildData['secure_media'] as Map<String, dynamic> ?? const {};
    final redditVideo =
        secureMedia['reddit_video'] as Map<String, dynamic> ?? const {};
    final fallbackUrl = redditVideo['fallback_url'] as String ?? '';
    // final dashPlaylistUrl = redditVideo['dash_url'] as String ?? '';
    return fallbackUrl.length > 0
        ? [
            DownloadInfo(
                type: DownloadType.mp4,
                name: '${_parseDownloadName(fallbackUrl)}$_videoFileSuffix.mp4',
                url: fallbackUrl),
          ]
        : null;
  }

  String _parseDownloadName(String url) {
    int indexOfTrailingSlash = url.indexOf('/', _redditVideoHostUrl.length);
    indexOfTrailingSlash =
        indexOfTrailingSlash != -1 ? indexOfTrailingSlash : null;
    return url.substring(_redditVideoHostUrl.length, indexOfTrailingSlash);
  }
}
