import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/seekr_controller.dart';
import 'core/app_config.dart';
import 'core/theme.dart';
import 'data/device_service.dart';
import 'services/tts_service.dart';
import 'views/home_view.dart';

void main() {
  // In a real build this is set by the flavor entry point (main_dev.dart etc.).
  AppConfig.flavor = Flavor.dev;

  // Dependency injection (registered once, before the app builds).
  // Swap FlutterTtsService() -> NoopTtsService() if TTS can't init on your platform.
  Get.put<DeviceService>(DeviceService());
  Get.put<TtsService>(FlutterTtsService());
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
