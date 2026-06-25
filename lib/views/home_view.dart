import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';

import '../controllers/seekr_controller.dart';
import '../domain/models.dart';
import 'camera_live_view.dart';
import 'widgets/camera_preview_box.dart';

/// Accessibility-first UI:
///  - every interactive element is wrapped in Semantics with a clear label
///  - connection + speaking cards are live regions (announced on change)
///  - SemanticsService.announce fires on mode change for screen-reader users
///  - large text + high contrast + dark mode (a real Seekr user request)
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SeekrController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seekr Companion'),
        actions: [
          IconButton(
            tooltip: 'Toggle dark mode',
            icon: const Icon(Icons.brightness_6),
            onPressed: () => Get.changeThemeMode(
              Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ConnectionCard(c: c),
              const SizedBox(height: 16),
              _CameraPreviewCard(c: c),
              const SizedBox(height: 16),
              Text('Modes', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _ModeGrid(c: c),
              const SizedBox(height: 16),
              _NowSpeakingCard(c: c),
              const SizedBox(height: 12),
              Text('Announcements',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              _SpokenLog(c: c),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.c});
  final SeekrController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = c.connection.value;
      final label = switch (state) {
        DeviceConnectionState.disconnected => 'Device disconnected',
        DeviceConnectionState.connecting => 'Connecting to device',
        DeviceConnectionState.connected => 'Device connected',
      };
      return Semantics(
        liveRegion: true,
        label: label,
        child: Card(
          child: ListTile(
            leading: Icon(
              state == DeviceConnectionState.connected
                  ? Icons.wifi
                  : Icons.wifi_off,
            ),
            title: Text(label),
            subtitle: Obx(() => Text(
                  c.lastDistance.value == null
                      ? 'No readings yet'
                      : 'Nearest object: ${c.lastDistance.value!.toStringAsFixed(1)} m',
                )),
            trailing: state == DeviceConnectionState.disconnected
                ? FilledButton(
                    onPressed: c.connect,
                    child: const Text('Connect'),
                  )
                : null,
          ),
        ),
      );
    });
  }
}

class _ModeGrid extends StatelessWidget {
  const _ModeGrid({required this.c});
  final SeekrController c;

  static const _modes = <SeekrMode>[
    SeekrMode.textRecognition,
    SeekrMode.sceneDetection,
    SeekrMode.depthObstacle,
    SeekrMode.supermarket,
  ];

  static const _icons = <SeekrMode, IconData>{
    SeekrMode.textRecognition: Icons.text_fields_rounded,
    SeekrMode.sceneDetection: Icons.image_search_rounded,
    SeekrMode.depthObstacle: Icons.sensors_rounded,
    SeekrMode.supermarket: Icons.shopping_basket_rounded,
  };

  static const _colors = <SeekrMode, Color>{
    SeekrMode.textRecognition: Color(0xFF2196F3),
    SeekrMode.sceneDetection: Color(0xFF4CAF50),
    SeekrMode.depthObstacle: Color(0xFFFF5722),
    SeekrMode.supermarket: Color(0xFF9C27B0),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final active = c.activeMode.value;
      return GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 150,
        ),
        children: _modes.map((m) {
          final selected = active == m;
          final color = _colors[m]!;
          return Semantics(
            button: true,
            selected: selected,
            label: selected
                ? '${m.label} active. Tap to stop.'
                : '${m.label} mode. ${m.description}',
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: selected
                        ? color.withAlpha(30)
                        : cs.surfaceContainerHighest,
                    border: Border.all(
                      color: selected ? color : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                                color: color.withAlpha(60),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : [],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      c.toggleMode(m);
                      SemanticsService.announce(
                        selected
                            ? '${m.label} stopped'
                            : '${m.label} activated',
                        TextDirection.ltr,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(_icons[m],
                              color: selected ? color : cs.onSurfaceVariant,
                              size: 26),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                m.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: selected ? color : cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                m.description,
                                style: TextStyle(
                                    fontSize: 11, color: cs.onSurfaceVariant),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Semantics(
                      button: true,
                      label: 'Stop ${m.label}',
                      child: IconButton.filledTonal(
                        tooltip: 'Stop ${m.label}',
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        onPressed: () {
                          c.stopMode();
                          SemanticsService.announce(
                            '${m.label} stopped',
                            TextDirection.ltr,
                          );
                        },
                        icon: Icon(Icons.close_rounded, color: color),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}

class _NowSpeakingCard extends StatelessWidget {
  const _NowSpeakingCard({required this.c});
  final SeekrController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final speaking = c.nowSpeaking.value;
      final isSpeaking = speaking != null;
      return Semantics(
        liveRegion: true,
        child: Card(
          color: isSpeaking
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            leading: Icon(isSpeaking ? Icons.volume_up : Icons.volume_off),
            title: Text(speaking ?? 'Silent'),
            subtitle: const Text('Now speaking'),
            trailing: isSpeaking
                ? IconButton(
                    tooltip: 'Stop speaking',
                    onPressed: c.stopSpeaking,
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
          ),
        ),
      );
    });
  }
}

class _SpokenLog extends StatelessWidget {
  const _SpokenLog({required this.c});
  final SeekrController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() => ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56, maxHeight: 220),
          child: c.spokenLog.isEmpty
              ? const Center(
                  child: Text('Spoken announcements will appear here.'),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: c.spokenLog.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.record_voice_over),
                    title: Text(c.spokenLog[i]),
                  ),
                ),
        ));
  }
}

/// Camera preview + Describe trigger button.
/// Shows live preview when the camera is initialized; gracefully shows a
/// placeholder when running on web/test (SimulatedImageSource).
class _CameraPreviewCard extends StatelessWidget {
  const _CameraPreviewCard({required this.c});
  final SeekrController c;

  void _openLiveCamera() {
    final mode = c.activeMode.value == SeekrMode.none
        ? SeekrMode.sceneDetection
        : c.activeMode.value;
    Get.to<void>(
      () => CameraLiveView(initialMode: mode),
      transition: Transition.downToUp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reactive preview: tap opens full-screen live camera.
          Obx(() {
            final ctrl = c.cameraController.value;
            if (ctrl != null && ctrl.value.isInitialized) {
              return GestureDetector(
                onTap: _openLiveCamera,
                child: Semantics(
                  label: 'Camera preview. Tap to open live camera.',
                  child: SizedBox(
                    height: 220,
                    child: CameraPreviewBox(controller: ctrl),
                  ),
                ),
              );
            }
            return GestureDetector(
              onTap: _openLiveCamera,
              child: const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, size: 48),
                      SizedBox(height: 8),
                      Text('Camera preview'),
                      Text('Tap to open live camera',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          }),
          // Describe button — opens live camera screen.
          Semantics(
            button: true,
            label: 'Open live camera to describe what the camera sees',
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                onPressed: _openLiveCamera,
                icon: const Icon(Icons.videocam_rounded),
                label: const Text('Describe'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
