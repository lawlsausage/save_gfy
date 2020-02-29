import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:save_gfy/services/file_service.dart';
import 'package:save_gfy/services/logger_service.dart';

/// A [Function] which accepts [subscription] and [totalBytes] parameters where:
///
/// - [subscription] - The [StreamSubscription] to override the listening of the
/// response data.
/// - [totalBytes] - The total number of bytes (size) of the download file.
typedef void OnDownloadStartedCallback(
    StreamSubscription subscription, int totalBytes);

/// A [Function] which accepts [receivedBytes] and [totalBytes] parameters where:
///
/// - [receivedBytes] - The number of bytes downloaded from the response [StreamSubscription]
/// at a point of time.
/// - [totalBytes] - The total number of bytes (size) of the download file.
typedef void OnDownloadProgressCallback(int receivedBytes, int totalBytes);

/// A [Function] which accepts a [filePath] parameter which is the fully qualified
/// file name with path of the saved file.
typedef void OnDownloadFinishedCallback(String filePath);

/// Handles HTTP interactions to download various types of resources from the web.
class DownloadService {
  DownloadService(
    this.httpClient,
    this.fileService,
    this.loggerService,
  );

  final HttpClient httpClient;

  final FileService fileService;

  final LoggerService loggerService;

  /// Downloads a file from the provided [url] to a file for the provided [filePath].
  /// HTTP resource interaction is handled on the [DownloadService.httpClient] while
  /// file system interaction is via [DownloadService.fileService].
  ///
  /// The order of the callback [Function]s are as follows:
  ///
  /// 1. [onDownloadStarted] - Invoked when the HTTP response is listened to and a
  /// [StreamSubscription] had been created.
  /// 2. [onDownloadProgress] - Invoked as data is streamed from the HTTP response.
  /// 3. [onDownloadFinished] - Invoked after the [StreamSubscription] of the HTTP
  /// response had finished.
  Future<String> downloadFile({
    @required String url,
    @required String filePath,
    OnDownloadStartedCallback onDownloadStarted,
    OnDownloadProgressCallback onDownloadProgress,
    OnDownloadFinishedCallback onDownloadFinished,
  }) async {
    assert(url != null);
    assert(filePath != null);

    final saveFile = fileService.createFile(filePath);

    try {
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      final statusCode = response.statusCode;
      final totalBytes = response.contentLength;
      final handleListen = (StreamSubscription subscription) {
        onDownloadStarted?.call(subscription, totalBytes);
      };

      if (statusCode != HttpStatus.ok && statusCode != HttpStatus.notModified) {
        throw ('$statusCode: Unable to download');
      }

      fileService.deleteFileSync(saveFile);
      saveFile.createSync();

      await _listenOnResponse(
        response,
        saveFile,
        handleListen,
        onDownloadProgress,
      );
      onDownloadFinished?.call(saveFile.path);
    } catch (err) {
      fileService.deleteFileSync(saveFile);
      rethrow;
    }
    return saveFile.path;
  }

  Future _listenOnResponse(
      HttpClientResponse response,
      File file,
      void Function(StreamSubscription) onListen,
      OnDownloadProgressCallback onDownloadProgress) {
    final completer = Completer<List<int>>();

    try {
      int dataLength = 0;
      int received = 0;
      final totalBytes = response.contentLength;

      StreamSubscription<List<int>> subscription = response.listen(
        (data) {
          dataLength += data.length;
          file.writeAsBytesSync(data, mode: FileMode.append);
          received = dataLength;
          onDownloadProgress?.call(received, totalBytes);
        },
        onDone: () {
          try {
            onDownloadProgress?.call(received, totalBytes);
            loggerService.d('${file.lengthSync()}:$totalBytes');
            completer.complete();
          } catch (err) {
            completer.completeError(err);
          }
        },
        onError: (e) {
          completer.completeError(e);
        },
      );
      onListen?.call(subscription);
    } catch (err) {
      completer.completeError(err);
    }

    return completer.future;
  }

  /// Retrieves [String] data from the provided [url] parameter.
  ///
  /// HTTP resource interaction is handled on the [DownloadService.httpClient].
  Future<String> getData(String url) async {
    assert(url != null);

    String jsonString = '';
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    await for (String content in response.transform(Utf8Decoder())) {
      jsonString += content;
    }
    return jsonString;
  }
}
