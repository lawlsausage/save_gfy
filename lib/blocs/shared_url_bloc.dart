import 'dart:async';

import 'package:rxdart/subjects.dart';

/// [SharedUrlBloc] provides control over shared URL state per instance. A shared URL
/// may be a URL provided to the app via copy/paste, OS share panels, etc.
class SharedUrlBloc {
  final sharedUrlStreamController = BehaviorSubject<String>();
  Stream<String> get getSharedUrl => sharedUrlStreamController.stream;

  /// Add a [url] to the [getSharedUrl] [Stream].
  void add(String url) {
    sharedUrlStreamController.add(url);
  }

  /// Provide a [Function] to the [onData] parameter to attach a listener to the shared URL
  /// [Stream]. 
  void listen(void Function(String) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    sharedUrlStreamController.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void dispose() {
    sharedUrlStreamController.close();
  }
}

/// A global instance of [SharedUrlBloc] which other modules can attach listeners or
/// add URLs to.
final sharedUrlBloc = SharedUrlBloc();
