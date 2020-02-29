import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:save_gfy/values/reddit/reddit_video_metadata.dart';

import '../../config.dart';

List<dynamic> createMockJson({
  String fallbackUrl,
  String dashUrl,
}) {
  return [
    {
      'data': {
        'children': [
          {
            'data': {
              'secure_media': {
                'reddit_video': {
                  'fallback_url': fallbackUrl,
                  'dash_url': dashUrl,
                },
              },
            },
          },
        ],
      },
    },
  ];
}

void main() {
  configureEnvironment();

  group('RedditVideoMetadata', () {
    group('fromJson', () {
      test('returns RedditVideoMetadata from valid JSON', () {
        final mockedFallbackUrl = 'https://reddit.com/${mockString()}/';
        final mockedDashUrl = mockString();
        final mockedJson = createMockJson(
          fallbackUrl: mockedFallbackUrl,
          dashUrl: mockedDashUrl,
        );

        final result = RedditVideoMetadata.fromJson(mockedJson);

        expect(result, isNotNull);
        expect(result.dashPlaylistUrl, equals(mockedDashUrl));
        expect(result.downloadInfoList, hasLength(1));
      });

      test('returns null for null [json] parameter', () {
        final result = RedditVideoMetadata.fromJson(null);

        expect(result, isNull);
      });

      test('returns null for non-list [json] parameter', () {
        final result = RedditVideoMetadata.fromJson(Map<String, dynamic>());

        expect(result, isNull);
      });

      test('throws for malformed JSON', () {
        final mockedJson = [
          {
            'data': {
              'children': [
                {},
              ],
            },
          },
        ];

        expect(
          () => RedditVideoMetadata.fromJson(mockedJson),
          throwsA(anything),
        );
      });
    });
  });
}
