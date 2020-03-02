import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/http_client_service.dart';

import '../config.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  configureEnvironment();

  group('HttpClientService', () {
    group('httpClient', () {
      test('returns an HttpClient instance', () {
        final service = HttpClientService(() => MockHttpClient());

        final httpClient1 = service.httpClient;
        final httpClient2 = service.httpClient;
        
        expect(httpClient1, isNotNull);
        expect(httpClient2, isNotNull);
        expect(identical(httpClient1, httpClient2), isFalse);
      });
    });
  });
}
