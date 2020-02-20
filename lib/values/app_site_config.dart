class AppSiteConfig {
  AppSiteConfig({this.hosts});

  static AppSiteConfig fromJson(Map<String, dynamic> json) {
    return AppSiteConfig(
      hosts: (json != null && json is Map<String, dynamic>)
          ? json['hosts']?.cast<String>()
          : null,
    );
  }

  final List<String> hosts;
}
