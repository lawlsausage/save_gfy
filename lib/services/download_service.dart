import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:save_gfy/services/logger_service.dart';

typedef void OnDownloadStartedCallback(
    StreamSubscription subscription, int totalBytes);
typedef void OnDownloadProgressCallback(int receivedBytes, int totalBytes);
typedef void OnDownloadFinishedCallback(String filepath);
typedef void OnListenCallback(StreamSubscription subscription);

class DownloadService {
  static bool trustSelfSigned = false;

  static HttpClient getHttpClient() {
    final httpClient = HttpClient()
      ..connectionTimeout = Duration(seconds: 10)
      ..maxConnectionsPerHost = 2
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    return httpClient;
  }

  static Future<String> downloadFile({
    String url,
    String filePath,
    OnDownloadStartedCallback onDownloadStarted,
    OnDownloadProgressCallback onDownloadProgress,
    OnDownloadFinishedCallback onDownloadFinished,
  }) async {
    assert(url != null);

    final saveFile = File(filePath);
    final httpClient = getHttpClient();

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

      if (saveFile.existsSync()) {
        saveFile.deleteSync();
      }
      saveFile.createSync();

      await _listenOnResponse(
          response, saveFile, handleListen, onDownloadProgress);
      onDownloadFinished?.call(saveFile.path);
    } catch (err) {
      if (saveFile.existsSync()) {
        saveFile.deleteSync();
      }
      rethrow;
    } finally {
      httpClient.close();
    }
    return saveFile.path;
  }

  static Future _listenOnResponse(
      HttpClientResponse response,
      File file,
      OnListenCallback onListen,
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

  static Future<String> getData(String url) async {
    assert(url != null);

    String jsonString = '';
    final httpClient = getHttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    await for (String content in response.transform(Utf8Decoder())) {
      jsonString += content;
    }
    return jsonString;
  }
}
