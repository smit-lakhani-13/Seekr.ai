/// Flavor configuration.
///
/// In a real build, the flavor is selected by separate entry points
/// (main_dev.dart / main_qa.dart / main_staging.dart / main_prod.dart),
/// each calling `AppConfig.flavor = ...` before runApp(). Each flavor would
/// also point at its own backend URL and its own Firebase project, so QA
/// can never touch production data.
enum Flavor { dev, qa, staging, prod }

class AppConfig {
  static Flavor flavor = Flavor.dev;

  static String get appName {
    switch (flavor) {
      case Flavor.dev:
        return 'Seekr Companion (Dev)';
      case Flavor.qa:
        return 'Seekr Companion (QA)';
      case Flavor.staging:
        return 'Seekr Companion (Staging)';
      case Flavor.prod:
        return 'Seekr Companion';
    }
  }

  static bool get showDebugBanner => flavor != Flavor.prod;

  /// Tier-2 backend URL, resolved in priority order:
  ///   1. --dart-define=BACKEND_URL=<url>  (CI / real-device / deployed build)
  ///   2. Per-flavor default (dev/QA → Android emulator host; staging/prod → TODO placeholders)
  ///
  /// Real device on LAN: flutter run --dart-define=BACKEND_URL=http://192.168.x.x:8000
  /// Deployed: flutter build apk --dart-define=BACKEND_URL=https://your-gcp-url
  static const String _backendUrlEnv = String.fromEnvironment('BACKEND_URL');

  static String get backendUrl {
    if (_backendUrlEnv.isNotEmpty) return _backendUrlEnv;
    // switch (flavor) {
    //   case Flavor.dev:
    //   case Flavor.qa:
    //     return 'http://10.0.2.2:8000'; // Android emulator → host machine
    //   case Flavor.staging:
    //     return 'https://staging-seekr-api.example.com'; // TODO(human): replace with real staging URL
    //   case Flavor.prod:
    //     return 'https://seekr-vision-api-agk63t25ja-el.a.run.app'; // Live Cloud Run backend
    // }
    // Default all environments (including dev/emulator runs) to the live production
    // GCP Cloud Run backend. This ensures the app works out-of-the-box with real Azure
    // OpenAI GPT-4o-vision descriptions. To test a local backend on an emulator,
    // run: flutter run --dart-define=BACKEND_URL=http://10.0.2.2:8000
    return 'https://seekr-vision-api-agk63t25ja-el.a.run.app';
  }
}
