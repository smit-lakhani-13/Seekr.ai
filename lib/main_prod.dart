import 'core/app_config.dart';
import 'main.dart';

// Production: flutter build apk --dart-define=BACKEND_URL=https://your-gcp-url --target=lib/main_prod.dart
void main() => bootstrap(Flavor.prod);
