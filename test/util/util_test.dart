import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:save_gfy/util/util.dart';

main() {
  group('Util', () {
    group('remap', () {
      test('remap returns a new value within the provided range', () {
        final originalMinValue = 0;
        final originalMaxValue = 100;
        final originalValue =
            mockInteger(originalMinValue, originalMaxValue).toDouble();
        final originalRatio =
            (originalMaxValue - originalMinValue) / originalValue;
        final translatedMinValue = 0;
        final translatedMaxValue = mockInteger(1, 50);

        final result = Util.remap(
          originalValue,
          originalMinValue.toDouble(),
          originalMaxValue.toDouble(),
          translatedMinValue.toDouble(),
          translatedMaxValue.toDouble(),
        );
        final resultRatio = (translatedMaxValue - translatedMinValue) / result;

        expect(result, isNotNaN);
        expect(
            result, inInclusiveRange(translatedMinValue, translatedMaxValue));
        expect(resultRatio, closeTo(originalRatio, 0.05));
      });

      test('remap returns 0 if original max and min value are the same', () {
        final originalValue = mockInteger(0, 100).toDouble();
        final result = Util.remap(originalValue, 2, 2, 0, 1);

        expect(result, isNotNaN);
        expect(result, equals(0));
      });
    });

    group('makeHttps', () {
      test(
          'makeHttps appends https:// if http:// or https:// not included in String',
          () {
        final mockedUrl = mockString();
        final result = Util.makeHttps(mockedUrl);

        expect(result, isNot(equals(mockedUrl)));
        expect(result, startsWith('https://'));
        expect(result.indexOf(mockedUrl), equals('https://'.length));
      });

      test('makeHttps returns null for null [url] parameter', () {
        final result = Util.makeHttps(null);

        expect(result, isNull);
      });

      test('makeHttps converts http:// to https:// when included in the String',
          () {
        final mockedUrl = 'http://' + mockString();
        final result = Util.makeHttps(mockedUrl);

        expect(result, isNot(equals(mockedUrl)));
        expect(result, startsWith('https://'));
      });
    });
  });
}
