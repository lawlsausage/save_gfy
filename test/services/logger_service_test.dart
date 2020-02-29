import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/services/logger_service.dart';

import '../config.dart';

class MockLogger extends Mock implements Logger {}

class MockStackTrace extends Mock implements StackTrace {}

typedef void LogMethod(dynamic message, [dynamic error, StackTrace stackTrace]);

void _testLogMethod(LogMethod Function(MockLogger) onSetupMockLogger,
    LogMethod Function(LoggerService) onLoggerServiceLog) {
  assert(onSetupMockLogger != null);
  assert(onLoggerServiceLog != null);

  final mockLogger = MockLogger();
  final mockedMessage = mockString();
  final mockedError = mockString();
  final mockStackTrace = MockStackTrace();
  var logCount = 0;

  final mockedMethod = onSetupMockLogger(mockLogger);

  when(mockedMethod(
    argThat(equals(mockedMessage)),
    argThat(equals(mockedError)),
    argThat(equals(mockStackTrace)),
  )).thenAnswer((_) {
    logCount += 1;
  });

  final service = LoggerService(mockLogger);
  final serviceLogMethod = onLoggerServiceLog(service);
  serviceLogMethod(mockedMessage, mockedError, mockStackTrace);

  expect(logCount, equals(1));
}

void main() {
  configureEnvironment();

  group('LoggerService', () {
    group('close', () {
      test('closes the Logger', () {
        final mockLogger = MockLogger();
        var closeCount = 0;

        when(mockLogger.close()).thenAnswer((_) {
          closeCount += 1;
        });

        final service = LoggerService(mockLogger);
        service.close();

        expect(closeCount, equals(1));
      });
    });

    group('log methods', () {
      const description = 'calls underlying Logger method equivalent';

      test('d $description', () {
        _testLogMethod(
          (mockLogger) => mockLogger.d,
          (service) => service.d,
        );
      });

      test('e $description', () {
        _testLogMethod(
          (mockLogger) => mockLogger.e,
          (service) => service.e,
        );
      });

      test('i $description', () {
        _testLogMethod(
          (mockLogger) => mockLogger.i,
          (service) => service.i,
        );
      });

      test('v $description', () {
        _testLogMethod(
          (mockLogger) => mockLogger.v,
          (service) => service.v,
        );
      });

      test('w $description', () {
        _testLogMethod(
          (mockLogger) => mockLogger.w,
          (service) => service.w,
        );
      });

      test('wtf $description', () {
        _testLogMethod(
          (mockLogger) => mockLogger.wtf,
          (service) => service.wtf,
        );
      });
    });
  });
}
