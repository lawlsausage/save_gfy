import 'dart:io';

class HttpClientService {
  HttpClientService() {
    reset();
  }

  final httpClient = HttpClient();

  bool trustSelfSigned = false;

  void reset() {
    httpClient
      ..connectionTimeout = Duration(seconds: 10)
      ..maxConnectionsPerHost = 2
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
  }

  void dispose() {
    httpClient.close();
  }
}
