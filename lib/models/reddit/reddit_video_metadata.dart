import 'package:save_gfy/services/reddit_service.dart';
import 'package:save_gfy/values/download_info.dart';
import 'package:save_gfy/values/download_type.dart';

class RedditVideoMetadata {
  RedditVideoMetadata({this.dashPlaylistUrl, this.downloadInfoList});

  final String dashPlaylistUrl;

  final List<DownloadInfo> downloadInfoList;

  static RedditVideoMetadata fromJson(dynamic json) {
    final rootListings = json as List<dynamic>;

    if (rootListings == null) {
      return null;
    }

    final firstListing = rootListings.first as Map<String, dynamic>;
    final data = firstListing['data'];
    final children = data['children'] as List<dynamic>;
    final firstChild = children.first as Map<String, dynamic>;
    final firstChildData =
        firstChild['data'] as Map<String, dynamic> ?? const {};
    final secureMedia =
        firstChildData['secure_media'] as Map<String, dynamic> ?? const {};
    final redditVideo =
        secureMedia['reddit_video'] as Map<String, dynamic> ?? const {};
    final fallbackUrl = redditVideo['fallback_url'] as String ?? '';
    final dashPlaylistUrl = redditVideo['dash_url'] as String ?? '';
    final downloadInfoList = fallbackUrl.length > 0
        ? [
            DownloadInfo(
              type: DownloadType.mp4,
              name:
                  '${RedditService.parseDownloadName(fallbackUrl)}${RedditService.videoFileSuffix}.mp4',
              url: fallbackUrl,
            ),
          ]
        : null;

    return RedditVideoMetadata(
      dashPlaylistUrl: dashPlaylistUrl,
      downloadInfoList: downloadInfoList,
    );
  }
}
