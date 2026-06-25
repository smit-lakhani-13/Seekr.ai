import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/seekr_controller.dart';
import 'core/app_config.dart';
import 'core/theme.dart';
import 'data/device_image_source.dart';
import 'data/device_service.dart';
import 'data/phone_camera_source.dart';
import 'services/cloud_vision_service.dart';
import 'services/connectivity_service.dart';
import 'services/local_vision_service.dart';
import 'services/tts_service.dart';
import 'services/vision_router.dart';
import 'views/home_view.dart';

/// Default entry point — dev flavor. CI and plain `flutter run` use this.
void main() => bootstrap(Flavor.dev);

/// Shared bootstrap called by every flavor entry point.
/// Sets flavor, wires DI, starts the app.
///
/// Build-time override: --dart-define=BACKEND_URL=https://your-gcp-url
void bootstrap(Flavor flavor) {
  AppConfig.flavor = flavor;

  Get.put<DeviceService>(DeviceService());
  Get.put<TtsService>(FlutterTtsService());
  Get.put<ConnectivityService>(ConnectivityServiceImpl());
  // Web uses SimulatedImageSource (no platform channels); Android uses real camera.
  Get.put<DeviceImageSource>(
      kIsWeb ? SimulatedImageSource() : PhoneCameraSource());
  // Tier-1 on-device: ML Kit on Android; no-op on web (falls through to cloud or graceful message).
  Get.put<LocalVisionService>(
      kIsWeb ? NoopLocalVisionService() : MlKitLocalVisionService());
  Get.put<CloudVisionService>(
      HttpCloudVisionService(Get.find<ConnectivityService>()));
  Get.put<VisionRouter>(VisionRouter(
    Get.find<LocalVisionService>(),
    Get.find<CloudVisionService>(),
    Get.find<ConnectivityService>(),
  ));
  Get.put<SeekrController>(
    SeekrController(Get.find<DeviceService>(), Get.find<TtsService>()),
  );

  runApp(const SeekrApp());
}

class SeekrApp extends StatelessWidget {
  const SeekrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: AppConfig.showDebugBanner,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // honours OS setting; toggle in the app bar
      home: const HomeView(),
    );
  }
}
