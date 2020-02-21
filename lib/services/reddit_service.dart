import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:save_gfy/main.dart';
import 'package:save_gfy/models/xml/xml_document.dart';
import 'package:save_gfy/services/download_service.dart';
import 'package:save_gfy/services/logger_service.dart';
import 'package:save_gfy/services/source_service.dart';
import 'package:save_gfy/values/download_info.dart';
import 'package:save_gfy/values/download_type.dart';
import 'package:save_gfy/values/reddit/dash_info.dart';
import 'package:save_gfy/values/reddit/reddit_video_metadata.dart';
import 'package:save_gfy/values/source_metadata.dart';

class RedditService implements SourceService {
  static const String redditVideoHostUrl = 'https://v.redd.it/';

  static const String videoFileSuffix = '_savegfyorig';

  static const String audioFileSuffix = '_savegfyorig_audio';

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
        (await _getVDotReddDotItDownload(_currentUrl));

    return SourceMetadata(
      name: ((downloads?.length ?? 0) > 0)
          ? parseDownloadName(downloads[0].url)
          : '',
      downloads: downloads,
      sourceUrl: _currentUrl,
    );
  }

  @override
  Future download(
    String downloadsPath,
    DownloadInfo downloadInfo,
    SourceMetadata metadata,
    void Function(int, int) onDownloadProgress, {
    void Function(StreamSubscription) onDownloadStarted,
  }) async {
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

  Future<String> _downloadVideo(
    String downloadsPath,
    String url,
    DownloadInfo downloadInfo,
    void Function(int, int) onDownloadProgress, {
    void Function(StreamSubscription) onDownloadStarted,
  }) async {
    final filePath = '$downloadsPath/${downloadInfo.name}';
    try {
      await DownloadService.downloadFile(
        url: url,
        filePath: filePath,
        onDownloadProgress: onDownloadProgress,
        onDownloadStarted: (subscription, totalBytes) =>
            onDownloadStarted?.call(subscription),
      );
      return filePath;
    } catch (err) {
      return null;
    }
  }

  Future<String> _downloadAudio(
    String downloadsPath,
    String url,
    DownloadInfo downloadInfo,
    void Function(int, int) onDownloadProgress, {
    void Function(StreamSubscription) onDownloadStarted,
  }) async {
    try {
      final name =
          downloadInfo.name.replaceAll(videoFileSuffix, audioFileSuffix);
      final filePath = '$downloadsPath/$name';
      await DownloadService.downloadFile(
        url: url,
        filePath: filePath,
        onDownloadProgress: onDownloadProgress,
        onDownloadStarted: (subscription, totalBytes) =>
            onDownloadStarted?.call(subscription),
      );
      return filePath;
    } catch (err) {
      return null;
    }
  }

  Future _mergeFiles(List<String> filePaths) async {
    final outputFilePath = filePaths[0].replaceAll(videoFileSuffix, '');
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

    final formattedUrl = _formatRedditVideoMetadataUrl(url);
    final jsonString = await DownloadService.getData(formattedUrl);
    final json = jsonDecode(jsonString);
    final metadata = RedditVideoMetadata.fromJson(json);
    var downloadInfoList = metadata.downloadInfoList;
    final dashPlaylist = await _getDashPlaylist(metadata.dashPlaylistUrl);
    final parsedDownloadName = parseDownloadName(metadata.dashPlaylistUrl);
    final parsedDownloadUrl = metadata.dashPlaylistUrl
        .substring(0, metadata.dashPlaylistUrl.toLowerCase().indexOf('dash'));
    downloadInfoList = _transformDashPlaylistToDownloadInfo(
            dashPlaylist, parsedDownloadName, parsedDownloadUrl) ??
        downloadInfoList;
    return downloadInfoList;
  }

  Future<List<DownloadInfo>> _getVDotReddDotItDownload(String url) async {
    if (!(url?.toLowerCase()?.contains('v.redd.it') ?? false)) {
      return null;
    }
    final parsedDownloadName = parseDownloadName(url);
    final parsedDownloadUrl =
        url.substring(0, url.toLowerCase().indexOf('dash'));
    var downloadInfoList = [
      DownloadInfo(
        type: DownloadType.mp4,
        name: '${parseDownloadName(url)}$videoFileSuffix.mp4',
        url: url,
      ),
    ];
    final dashPlaylist =
        await _getDashPlaylist('${parsedDownloadUrl}DASHPlaylist.mpd');
    downloadInfoList = _transformDashPlaylistToDownloadInfo(
            dashPlaylist, parsedDownloadName, parsedDownloadUrl) ??
        downloadInfoList;
    return downloadInfoList;
  }

  Future<List<DashInfo>> _getDashPlaylist(String url) async {
    final lowerCaseUrl = url?.toLowerCase() ?? '';
    if (!lowerCaseUrl.contains('v.redd.it') || !lowerCaseUrl.contains('dash')) {
      return null;
    }

    final resolvedUrl = !lowerCaseUrl.contains('dashplaylist.mpd')
        ? url.substring(0, lowerCaseUrl.indexOf('dash'))
        : url;
    final xmlString = await DownloadService.getData(resolvedUrl);
    final representationXmlElements = XmlDocument.fromString(xmlString)
        ?.findElements('MPD')
        ?.first
        ?.findElements('Period')
        ?.first
        ?.findElements('AdaptationSet')
        ?.first
        ?.findElements('Representation');
    return representationXmlElements
        ?.map((element) => DashInfo.fromXml(element))
        ?.toList();
  }

  List<DownloadInfo> _transformDashPlaylistToDownloadInfo(
    List<DashInfo> dashPlaylist,
    String downloadName,
    String downloadUrl,
  ) {
    try {
      return ((dashPlaylist?.length ?? 0) > 0)
          ? dashPlaylist
              .map((record) => DownloadInfo(
                    type: downloadTypeFromMimeType(record.mimeType),
                    name: '${downloadName}_${record.width}$videoFileSuffix.mp4',
                    url: '$downloadUrl${record.baseUrl}',
                    quality: record.width.toString() + 'p',
                  ))
              .toList()
          : null;
    } catch (err) {
      loggerService.d('Unable to parse DASHPlaylist', err);
    }

    return null;
  }

  String _formatRedditVideoMetadataUrl(String url) {
    String formattedUrl = url;
    if (!formattedUrl.endsWith('/')) {
      formattedUrl += '/';
    }
    return formattedUrl + '.json';
  }

  static String parseDownloadName(String url) {
    int indexOfTrailingSlash = url.indexOf('/', redditVideoHostUrl.length);
    indexOfTrailingSlash =
        indexOfTrailingSlash != -1 ? indexOfTrailingSlash : null;
    return url.substring(redditVideoHostUrl.length, indexOfTrailingSlash);
  }
}
