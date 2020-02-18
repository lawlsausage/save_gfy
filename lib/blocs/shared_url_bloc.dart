import 'dart:async';

import 'package:rxdart/subjects.dart';

class SharedUrlBloc {
  final sharedUrlStreamController = BehaviorSubject<String>();
  Stream<String> get getSharedUrl => sharedUrlStreamController.stream;

  void add(String event) {
    sharedUrlStreamController.add(event);
  }

  void listen(void Function(String) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    sharedUrlStreamController.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

final sharedUrlBloc = SharedUrlBloc();
