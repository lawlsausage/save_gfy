import 'package:rxdart/subjects.dart';
import 'package:save_gfy/util/util.dart';
import 'package:save_gfy/values/download_progress_metadata.dart';

class DownloadBloc {
  DownloadBloc() {
    _initDownloadProgressStream();
  }

  final totalStreamController = BehaviorSubject<int>()..add(0);
  Stream<int> get getTotal => totalStreamController.stream;

  final receivedStreamController = BehaviorSubject<int>()..add(0);
  Stream<int> get getReceived => receivedStreamController.stream;

  final progressStreamController = BehaviorSubject<double>()..add(0.0);
  Stream<double> get getProgress => progressStreamController.stream;

  final downloadProgressStreamController =
      BehaviorSubject<DownloadProgressMetadata>()
        ..add(DownloadProgressMetadata(received: 0, total: 0));
  Stream<DownloadProgressMetadata> get getProgressMetadata =>
      downloadProgressStreamController.stream;

  void update(int received, int total) {
    final newProgress = double.parse(
        Util.remap(received.toDouble(), 0, total.toDouble(), 0, 1)
            .toStringAsFixed(2));
    final currentTotal = totalStreamController.value;
    final currentProgress = progressStreamController.value;

    if (total != currentTotal) {
      updateTotal(total);
    }

    if (newProgress != currentProgress) {
      updateReceived(received);
      updateProgress(newProgress);
    }
  }

  void updateTotal(int value) {
    totalStreamController.sink.add(value);
  }

  void updateReceived(int value) {
    receivedStreamController.sink.add(value);
  }

  void updateProgress(double value) {
    progressStreamController.sink.add(value);
  }

  void updateProgressMetadata() {
    downloadProgressStreamController.sink.add(DownloadProgressMetadata(
      received: receivedStreamController.value,
      total: totalStreamController.value,
    ));
  }

  void _initDownloadProgressStream() {
    getReceived.listen((_) => updateProgressMetadata());
    getTotal.listen((_) => updateProgressMetadata());
  }

  void dispose() {
    totalStreamController.close();
    receivedStreamController.close();
    progressStreamController.close();
    downloadProgressStreamController.close();
  }
}
