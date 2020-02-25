import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:save_gfy/blocs/shared_url_bloc.dart';

import '../config.dart';

void main() {
  configureEnvironment();

  group('SharedUrlBloc', () {
    test('getSharedUrl returns a Stream<String> instance', () {
      final bloc = SharedUrlBloc();
      final stream = bloc.getSharedUrl;

      expect(stream, isNotNull);
      expect(stream, isA<Stream<String>>());
    });

    test('listen attaches handler and receives data', () async {
      final completer = Completer<int>();
      var broadcastCount = 0;
      var handledCount = 0;
      final iterations = mockInteger(1, 10);
      final mockedData = mockRange<String>(mockString, iterations);
      final bloc = SharedUrlBloc();
      bloc.listen((data) {
        expect(data, equals(mockedData[handledCount]));
        handledCount += 1;
        if (handledCount == iterations) {
          completer.complete(handledCount);
        }
      });

      mockedData.forEach((value) {
        broadcastCount += 1;
        bloc.sharedUrlStreamController.add(value);
      });

      expect(await completer.future, equals(broadcastCount));
    });

    test('add broadcasts data to listeners', () {
      final iterations = mockInteger(1, 10);
      final mockedData = mockRange<String>(mockString, iterations);
      final bloc = SharedUrlBloc();

      expectLater(bloc.getSharedUrl,
          emitsInOrder(mockedData.map((value) => emits(value))));

      mockedData.forEach((value) {
        bloc.add(value);
      });
    });
  });
}
