enum DownloadType {
  mp4,
  webm,
  unknown,
}

extension DownloadTypeExtension on DownloadType {
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

DownloadType downloadTypeFromMimeType(String mimeType) {
  return _mimeDownloadTypes[mimeType] ?? DownloadType.unknown;
}

class DownloadInfo {
  DownloadInfo({
    this.type,
    this.name,
    this.url,
    this.quality,
  });

  DownloadType type;

  String name;

  String url;

  String quality;
}
