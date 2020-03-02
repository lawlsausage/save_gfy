import 'dart:io';

typedef HttpClient HttpClientFactory();

class HttpClientService {
  HttpClientService(this._httpClientFactory);

  final HttpClientFactory _httpClientFactory;

  /// [httpClient] returns a new instance of [HttpClient] as created by
  /// the configured factory.
  HttpClient get httpClient => _httpClientFactory()
    ..connectionTimeout = Duration(seconds: 10)
    ..maxConnectionsPerHost = 2
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => trustSelfSigned);

  bool trustSelfSigned = false;
}
