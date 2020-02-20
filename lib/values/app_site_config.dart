class AppSiteConfig {
  AppSiteConfig({this.hosts});

  /// Parses [Map]`<String, dynamic>` parameter [json] into an [AppSiteConfig] object.
  ///
  /// If [json] is `null`, [AppSiteConfig.fromJson] will return `null`.
  static AppSiteConfig fromJson(Map<String, dynamic> json) {
    return (json != null && json is Map<String, dynamic>)
        ? AppSiteConfig(
            hosts: (json['hosts'] ?? []).cast<String>(),
          )
        : null;
  }

  final List<String> hosts;
}
