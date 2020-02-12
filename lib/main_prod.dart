import 'package:save_gfy/main.dart' as App;

/// The entrypoint to the app for Production builds using
/// `flutter run -t lib/main_prod.dart --flavor prod`.
void main() {
  // Set config to prod
  App.run(env: 'prod');
}
