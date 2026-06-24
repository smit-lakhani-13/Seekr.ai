/// Flavor configuration.
///
/// In a real build, the flavor is selected by separate entry points
/// (main_dev.dart / main_qa.dart / main_staging.dart / main_prod.dart),
/// each calling `AppConfig.flavor = ...` before runApp(). Each flavor would
/// also point at its own API base URL and its own Firebase project, so QA
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

  static String get apiBaseUrl {
    switch (flavor) {
      case Flavor.dev:
        return 'https://dev-api.seekr.example';
      case Flavor.qa:
        return 'https://qa-api.seekr.example';
      case Flavor.staging:
        return 'https://staging-api.seekr.example';
      case Flavor.prod:
        return 'https://api.seekr.example';
    }
  }

  static bool get showDebugBanner => flavor != Flavor.prod;
}
