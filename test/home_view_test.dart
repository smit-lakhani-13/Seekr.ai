import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seekr_companion_demo/controllers/seekr_controller.dart';
import 'package:seekr_companion_demo/data/device_image_source.dart';
import 'package:seekr_companion_demo/data/device_service.dart';
import 'package:seekr_companion_demo/services/cloud_vision_service.dart';
import 'package:seekr_companion_demo/services/connectivity_service.dart';
import 'package:seekr_companion_demo/services/local_vision_service.dart';
import 'package:seekr_companion_demo/services/tts_service.dart';
import 'package:seekr_companion_demo/services/vision_router.dart';
import 'package:seekr_companion_demo/domain/models.dart';
import 'package:seekr_companion_demo/views/home_view.dart';

void _registerDeps() {
  final conn = NoopConnectivityService();
  Get.put<TtsService>(NoopTtsService());
  Get.put<DeviceService>(DeviceService());
  Get.put<ConnectivityService>(conn);
  Get.put<DeviceImageSource>(SimulatedImageSource());
  Get.put<LocalVisionService>(NoopLocalVisionService());
  Get.put<CloudVisionService>(NoopCloudVisionService());
  Get.put<VisionRouter>(VisionRouter(
    Get.find<LocalVisionService>(),
    Get.find<CloudVisionService>(),
    conn,
  ));
  Get.put<SeekrController>(
    SeekrController(Get.find<DeviceService>(), Get.find<TtsService>()),
  );
  // addTearDown runs BEFORE widget disposal + timer checks (unlike tearDown)
  addTearDown(Get.reset);
}

void main() {
  setUp(_registerDeps);

  testWidgets('renders Seekr Companion app bar', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    expect(find.text('Seekr Companion'), findsOneWidget);
  });

  testWidgets('Connect button visible when disconnected', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    expect(find.text('Connect'), findsOneWidget);
  });

  testWidgets('all four mode cards render by text', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    expect(find.text('Text Recognition'), findsOneWidget);
    expect(find.text('Scene Detection'), findsOneWidget);
    expect(find.text('Depth & Obstacle'), findsOneWidget);
    expect(find.text('Supermarket'), findsOneWidget);
  });

  testWidgets('mode card has Semantics button label', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    // Semantics(button:true, label:'${m.label} mode. ${m.description}')
    expect(find.bySemanticsLabel(RegExp(r'Text Recognition mode\.')),
        findsWidgets);
    expect(
        find.bySemanticsLabel(RegExp(r'Scene Detection mode\.')), findsWidgets);
    expect(
        find.bySemanticsLabel(RegExp(r'Depth.*Obstacle mode\.')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp(r'Supermarket mode\.')), findsWidgets);
  });

  testWidgets('Describe button has accessibility label', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    expect(
      find.bySemanticsLabel(RegExp(r'Describe', caseSensitive: false)),
      findsWidgets,
    );
  });

  testWidgets('Describe button text visible initially', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    expect(find.text('Describe'), findsOneWidget);
  });

  testWidgets('empty spoken log shows placeholder text', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    expect(find.text('Spoken announcements will appear here.'), findsOneWidget);
  });

  testWidgets('selectMode updates observable and Obx rebuilds UI',
      (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    final controller = Get.find<SeekrController>();
    expect(controller.activeMode.value, SeekrMode.none);
    controller.selectMode(SeekrMode.sceneDetection);
    await tester.pump();
    expect(controller.activeMode.value, SeekrMode.sceneDetection);
    // Switch to non-descriptive mode to cancel the periodic description timer
    // before test end (depthObstacle doesn't create a new timer).
    controller.selectMode(SeekrMode.depthObstacle);
    await tester.pump();
  });

  testWidgets('tapping active mode card toggles it off', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    final controller = Get.find<SeekrController>();

    await tester.ensureVisible(find.text('Scene Detection'));
    await tester.pump();
    await tester.tap(find.text('Scene Detection'));
    await tester.pump();
    expect(controller.activeMode.value, SeekrMode.sceneDetection);

    await tester.ensureVisible(find.text('Scene Detection'));
    await tester.pump();
    await tester.tap(find.text('Scene Detection'));
    await tester.pump();
    expect(controller.activeMode.value, SeekrMode.none);
  });

  testWidgets('Describe opens full-screen live camera view', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();

    await tester.ensureVisible(find.text('Describe'));
    await tester.pump();
    await tester.tap(find.text('Describe'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Text Recognition'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('architecture network status panel renders', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Network Pipeline'), findsOneWidget);
    expect(find.text('Frame source:'), findsOneWidget);
    expect(find.text('Phone Camera (demo)'), findsOneWidget);
    expect(find.text('Backend:'), findsOneWidget);
    expect(find.text('Cloud policy:'), findsOneWidget);
  });

  testWidgets('no layout overflow on 320x568 small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('no layout overflow at 1.5x text scale', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: GetMaterialApp(home: HomeView()),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
