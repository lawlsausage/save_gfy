/// Types of downloads which are handled by save_gfy.
enum DownloadType {
  mp4,
  webm,
  unknown,
}

/// Metadata for [DownloadType] enumerates.
extension DownloadTypeExtension on DownloadType {
  /// The String representation of the [DownloadType] enumeration.
  String get name => _downloadTypeNames[this];
}

const _mimeDownloadTypes = {
  'video/mp4': DownloadType.mp4,
  'video/webm': DownloadType.webm,
};

const _downloadTypeNames = {
  DownloadType.mp4: 'mp4',
  DownloadType.webm: 'webm',
  DownloadType.unknown: 'unknown',
};

/// Returns a [DownloadType] enumerate which corresponds with the
/// String passed via the [mimeType] parameter. A valid mime type value may
/// be 'video/mp4'. 
/// 
/// If the mime type passed is has not been implemented, [DownloadType.unknown]
/// will be returned.
/// 
/// If `null` is passed into [mimeType], [DownloadType.unknown] will be returned.
DownloadType downloadTypeFromMimeType(String mimeType) {
  final resolvedMimeType = mimeType ?? '';

  return _mimeDownloadTypes[resolvedMimeType] ?? DownloadType.unknown;
}
