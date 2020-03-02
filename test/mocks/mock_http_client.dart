import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {
  MockHttpClientResponse setupStatusCode(int statusCode) {
    when(this.statusCode).thenReturn(statusCode);
    return this;
  }

  MockHttpClientResponse setupContentLength(int contentLength) {
    when(this.contentLength).thenReturn(contentLength);
    return this;
  }

  MockHttpClientResponse setupListen(
    List<int> data, {
    void Function(StreamSubscription<List<int>>) onCreateStreamSubscription,
    void Function(PostExpectation<StreamSubscription<List<int>>>)
        onCreatedWhenExpectation,
  }) {
    final whenExpectation = when(this.listen(
      any,
      onError: anyNamed('onError'),
      onDone: anyNamed('onDone'),
      cancelOnError: anyNamed('cancelOnError'),
    ));
    final handleCreatedWhenExpectation = onCreatedWhenExpectation ??
        (expectation) {
          expectation.thenAnswer((invocation) {
            final void Function(List<int>) onData =
                invocation.positionalArguments[0];
            final void Function() onDone = invocation.namedArguments[#onDone];
            final void Function(dynamic) onError =
                invocation.namedArguments[#onError];
            final bool cancelOnError =
                invocation.namedArguments[#cancelOnError];
            final streamSubscription =
                new Stream<List<int>>.fromIterable(<List<int>>[data]).listen(
              onData,
              onDone: onDone,
              onError: onError,
              cancelOnError: cancelOnError,
            );
            onCreateStreamSubscription?.call(streamSubscription);
            return streamSubscription;
          });
        };

    handleCreatedWhenExpectation(whenExpectation);

    return this;
  }

  MockHttpClientResponse setupTransform(List<int> data,
      {StreamTransformer streamTransformer = const Utf8Decoder()}) {
    when(this.transform(argThat(isA<StreamTransformer>()))).thenAnswer((_) {
      return new Stream<List<int>>.fromIterable(<List<int>>[data])
          .transform(streamTransformer);
    });

    return this;
  }
}

class HttpClientMocks {
  final MockHttpClient httpClient = MockHttpClient();

  final MockHttpClientRequest request = MockHttpClientRequest();

  final MockHttpClientResponse response = MockHttpClientResponse();

  HttpClientMocks setup(String url) {
    when(request.close()).thenAnswer((_) => Future.value(response));
    when(httpClient.getUrl(Uri.parse(url)))
        .thenAnswer((_) => Future.value(request));

    return this;
  }
}
