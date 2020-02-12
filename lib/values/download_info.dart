enum DownloadType {
  mp4,
  webm,
  mp4Mobile,
}

class DownloadInfo {
  DownloadInfo({
    this.type,
    this.name,
    this.url,
  });

  DownloadType type;

  String name;

  String url;
}
