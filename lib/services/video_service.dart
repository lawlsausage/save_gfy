import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class VideoService {
  VideoService(this.flutterFFmpeg);

  final FlutterFFmpeg flutterFFmpeg;

  Future<int> mergeVideoAndAudio(
      String videoFilePath, String audioFilePath, String outputFilePath) async {
    assert((videoFilePath?.length ?? 0) > 0);
    assert((audioFilePath?.length ?? 0) > 0);
    assert((outputFilePath?.length ?? 0) > 0);

    final returnCode = await flutterFFmpeg.execute(
        '-i $videoFilePath -i $audioFilePath -c:v copy -c:a aac -strict experimental $outputFilePath');
    return returnCode;
  }
}
