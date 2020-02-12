enum Route { home, pasteUrl }

/// Metadata associated with [Route] enumerates.
extension RouteExtension on Route {
  String get path {
    switch (this) {
      case Route.pasteUrl:
        return '/pasteUrl';
      default:
        return '/';
    }
  }
}
