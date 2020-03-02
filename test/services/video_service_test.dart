import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/video_service.dart';

import '../config.dart';

class MockFlutterFFmpeg extends Mock implements FlutterFFmpeg {}

void main() {
  configureEnvironment();

  group('VideoService', () {
    group('mergeVideoAndAudio', () {
      test('passes video, audio, and output file paths as arguments to FFmpeg',
          () async {
        final mockedVideoFilePath = mockString();
        final mockedAudioFilePath = mockString();
        final mockedOutputFilePath = mockString();
        final mockFFmpeg = MockFlutterFFmpeg();
        var executeCount = 0;

        when(mockFFmpeg.execute(argThat(anything))).thenAnswer((invocation) {
          final ffMpegArgs = invocation.positionalArguments[0];
          expect(ffMpegArgs, isNotNull);
          expect(ffMpegArgs, contains(mockedVideoFilePath));
          expect(ffMpegArgs, contains(mockedAudioFilePath));
          expect(ffMpegArgs, contains(mockedOutputFilePath));
          executeCount += 1;
          return Future.value(0);
        });

        final service = VideoService(mockFFmpeg);
        final returnCode = await service.mergeVideoAndAudio(
            mockedVideoFilePath, mockedAudioFilePath, mockedOutputFilePath);

        expect(returnCode, equals(0));
        expect(executeCount, equals(1));
      });

      test('throws exception on empty or null video file path', () async {
        final random = mockInteger(0, 1);
        final mockedVideoFilePath = random == 1 ? '' : null;
        final mockedAudioFilePath = mockString();
        final mockedOutputFilePath = mockString();
        final mockFFmpeg = MockFlutterFFmpeg();
        final service = VideoService(mockFFmpeg);

        expect(
            () async => await service.mergeVideoAndAudio(
                mockedVideoFilePath, mockedAudioFilePath, mockedOutputFilePath),
            throwsA(anything));
      });

      test('throws exception on empty or null audio file path', () async {
        final random = mockInteger(0, 1);
        final mockedVideoFilePath = mockString();
        final mockedAudioFilePath = random == 1 ? '' : null;
        final mockedOutputFilePath = mockString();
        final mockFFmpeg = MockFlutterFFmpeg();
        final service = VideoService(mockFFmpeg);

        expect(
            () async => await service.mergeVideoAndAudio(
                mockedVideoFilePath, mockedAudioFilePath, mockedOutputFilePath),
            throwsA(anything));
      });

      test('throws exception on empty or null output file path', () async {
        final random = mockInteger(0, 1);
        final mockedVideoFilePath = mockString();
        final mockedAudioFilePath = mockString();
        final mockedOutputFilePath = random == 1 ? '' : null;
        final mockFFmpeg = MockFlutterFFmpeg();
        final service = VideoService(mockFFmpeg);

        expect(
            () async => await service.mergeVideoAndAudio(
                mockedVideoFilePath, mockedAudioFilePath, mockedOutputFilePath),
            throwsA(anything));
      });
    });
  });
}
