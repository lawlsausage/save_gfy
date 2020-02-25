import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:mockito/mockito.dart';
import 'package:save_gfy/models/xml/xml_element.dart';
import 'package:save_gfy/models/xml/xml_name.dart';
import 'package:save_gfy/values/reddit/dash_info.dart';

import '../../config.dart';

class MockXmlElement extends Mock implements XmlElement {}

class MockXmlName extends Mock implements XmlName {}

MockXmlElement createMockRepresentationXmlElement({
  String baseUrl,
  int height,
  int width,
  String mimeType,
}) {
  final mockedXmlName = MockXmlName();
  final mockedRepresentationXmlElement = MockXmlElement();
  final mockedBaseUrlXmlElement = MockXmlElement();

  when(mockedXmlName.local).thenReturn('Representation');

  when(mockedBaseUrlXmlElement.text).thenReturn(baseUrl);

  when(mockedRepresentationXmlElement.name).thenReturn(mockedXmlName);
  when(mockedRepresentationXmlElement.getAttribute('height'))
      .thenReturn(height?.toString());
  when(mockedRepresentationXmlElement.getAttribute('width'))
      .thenReturn(width?.toString());
  when(mockedRepresentationXmlElement.findElements('BaseURL'))
      .thenReturn(baseUrl != null ? [mockedBaseUrlXmlElement] : []);
  when(mockedRepresentationXmlElement.getAttribute('mimeType'))
      .thenReturn(mimeType);

  return mockedRepresentationXmlElement;
}

void main() {
  configureEnvironment();

  group('DashInfo', () {
    group('fromXml', () {
      test('successfully parses a Representation XmlElement', () {
        final mockedHeight = mockInteger(1, 100);
        final mockedWidth = mockInteger(1, 2000);
        final mockedMimeType = mockString();
        final mockedBaseUrl = mockString();
        final mockedXmlElement = createMockRepresentationXmlElement(
          baseUrl: mockedBaseUrl,
          height: mockedHeight,
          width: mockedWidth,
          mimeType: mockedMimeType,
        );

        final result = DashInfo.fromXml(mockedXmlElement);

        expect(result, isNotNull);
        expect(result.baseUrl, equals(mockedBaseUrl));
        expect(result.height, equals(mockedHeight));
        expect(result.width, equals(mockedWidth));
        expect(result.mimeType, equals(mockedMimeType));
      });

      test('defaults null height to 0', () {
        final mockedWidth = mockInteger(1, 2000);
        final mockedMimeType = mockString();
        final mockedBaseUrl = mockString();
        final mockedXmlElement = createMockRepresentationXmlElement(
          baseUrl: mockedBaseUrl,
          width: mockedWidth,
          mimeType: mockedMimeType,
        );

        final result = DashInfo.fromXml(mockedXmlElement);

        expect(result, isNotNull);
        expect(result.baseUrl, equals(mockedBaseUrl));
        expect(result.height, equals(0));
        expect(result.width, equals(mockedWidth));
        expect(result.mimeType, equals(mockedMimeType));
      });

      test('defaults null width to 0', () {
        final mockedHeight = mockInteger(1, 2000);
        final mockedMimeType = mockString();
        final mockedBaseUrl = mockString();
        final mockedXmlElement = createMockRepresentationXmlElement(
          baseUrl: mockedBaseUrl,
          height: mockedHeight,
          mimeType: mockedMimeType,
        );

        final result = DashInfo.fromXml(mockedXmlElement);

        expect(result, isNotNull);
        expect(result.baseUrl, equals(mockedBaseUrl));
        expect(result.height, equals(mockedHeight));
        expect(result.width, equals(0));
        expect(result.mimeType, equals(mockedMimeType));
      });

      test('defaults null base url to empty String', () {
        final mockedHeight = mockInteger(1, 100);
        final mockedWidth = mockInteger(1, 2000);
        final mockedMimeType = mockString();
        final mockedXmlElement = createMockRepresentationXmlElement(
          height: mockedHeight,
          width: mockedWidth,
          mimeType: mockedMimeType,
        );

        final result = DashInfo.fromXml(mockedXmlElement);

        expect(result, isNotNull);
        expect(result.baseUrl, equals(''));
        expect(result.height, equals(mockedHeight));
        expect(result.width, equals(mockedWidth));
        expect(result.mimeType, equals(mockedMimeType));
      });

      test('defaults null mimeType to empty String', () {
        final mockedHeight = mockInteger(1, 100);
        final mockedWidth = mockInteger(1, 2000);
        final mockedBaseUrl = mockString();
        final mockedXmlElement = createMockRepresentationXmlElement(
          baseUrl: mockedBaseUrl,
          height: mockedHeight,
          width: mockedWidth,
        );

        final result = DashInfo.fromXml(mockedXmlElement);

        expect(result, isNotNull);
        expect(result.baseUrl, equals(mockedBaseUrl));
        expect(result.height, equals(mockedHeight));
        expect(result.width, equals(mockedWidth));
        expect(result.mimeType, equals(''));
      });

      test('returns null for null [element] parameter', () {
        final result = DashInfo.fromXml(null);

        expect(result, isNull);
      });
    });
  });
}
