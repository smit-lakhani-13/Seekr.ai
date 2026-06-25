import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';

import '../core/app_config.dart';
import '../controllers/seekr_controller.dart';
import '../domain/models.dart';
import '../services/cloud_vision_service.dart';
import '../services/connectivity_service.dart';
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
              const _NetworkArchCard(),
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
    Get.to<void>(
      () => CameraLiveView(initialMode: c.activeMode.value),
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

// ── Network Pipeline card ────────────────────────────────────────────────────

/// Shows frame source + cloud route in real time — demonstrates the dual-network
/// solution (WifiNetworkSpecifier for device AP + per-socket cellular binding).
class _NetworkArchCard extends StatefulWidget {
  const _NetworkArchCard();

  @override
  State<_NetworkArchCard> createState() => _NetworkArchCardState();
}

class _NetworkArchCardState extends State<_NetworkArchCard> {
  List<ConnectivityResult> _types = [];
  StreamSubscription<List<ConnectivityResult>>? _sub;
  StreamSubscription<CloudRouteState>? _routeSub;
  Timer? _healthTimer;
  CloudHealth? _health;
  CloudRouteState _route = const CloudRouteState(
    preferCellular: false,
    cellularReady: false,
    lastMessage: 'Default internet route',
  );
  bool _checkingHealth = false;

  @override
  void initState() {
    super.initState();
    _route = Get.find<ConnectivityService>().cloudRouteState;
    _routeSub = Get.find<ConnectivityService>().cloudRouteStream.listen(
      (route) {
        if (mounted) setState(() => _route = route);
      },
    );
    _load();
    _refreshHealth();
    _healthTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshHealth(),
    );
    try {
      _sub = Connectivity().onConnectivityChanged.listen(
        (types) {
          if (mounted) setState(() => _types = types);
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  Future<void> _load() async {
    try {
      final types = await Connectivity().checkConnectivity();
      if (mounted) setState(() => _types = types);
    } catch (_) {}
  }

  Future<void> _refreshHealth() async {
    if (_checkingHealth) return;
    _checkingHealth = true;
    try {
      final health = await Get.find<CloudVisionService>().health();
      if (mounted) setState(() => _health = health);
    } catch (_) {
      if (mounted) {
        setState(() {
          _health = const CloudHealth(
            reachable: false,
            status: 'unavailable',
            message: 'Cloud service is not registered.',
          );
        });
      }
    } finally {
      _checkingHealth = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _routeSub?.cancel();
    _healthTimer?.cancel();
    super.dispose();
  }

  void _showArchDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dual-Network Architecture'),
        content: const SingleChildScrollView(
          child: Text(
            'The Seekr wearable creates its own local WiFi AP with no internet. '
            'The phone connects to receive camera frames.\n\n'
            'Problem: Android routes all traffic through the default network. '
            'If the device WiFi has no internet, cloud AI calls fail.\n\n'
            'Solution implemented here:\n'
            '• WifiNetworkSpecifier (Android 10+) makes the device AP '
            'app-scoped and local-only — never becomes the default route.\n'
            '• A separate cellular Network is held via ConnectivityManager. '
            'Cloud Tier-2 calls bind to this socket directly.\n'
            '• Per-socket binding (not bindProcessToNetwork) keeps both '
            'connections live simultaneously.\n\n'
            'Live camera mode stays on-device. Cloud calls send one compressed '
            'snapshot only when explicitly triggered.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasCellular = _types.contains(ConnectivityResult.mobile);
    final hasWifi = _types.contains(ConnectivityResult.wifi);
    final observedRoute = hasCellular
        ? 'mobile + ${hasWifi ? 'WiFi' : 'no WiFi'}'
        : hasWifi
            ? 'WiFi active'
            : 'Offline';
    final cloudRouteValue = _route.preferCellular
        ? (_route.cellularReady ? 'Mobile data' : 'Requesting mobile data')
        : 'Default internet';
    final health = _health;
    final backendValue = health == null
        ? 'Checking...'
        : health.reachable
            ? 'Reachable'
            : 'Unreachable';
    final backendDetail = health == null
        ? AppConfig.backendUrl
        : health.reachable
            ? 'Provider: ${health.provider ?? 'unknown'}'
            : '${health.status} — Tier-1 remains available';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.device_hub_rounded, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Network Pipeline',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  tooltip: 'How dual-network works',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showArchDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _NetRow(
              icon: Icons.camera_alt_rounded,
              label: 'Frame source',
              value: 'Phone Camera (demo)',
              detail: 'Production: Seekr device → local WiFi AP',
              color: Color(0xFF2196F3),
            ),
            const SizedBox(height: 6),
            _NetRow(
              icon: Icons.cloud_rounded,
              label: 'Observed internet',
              value: observedRoute,
              detail: hasWifi
                  ? 'WiFi can stay connected for device frames'
                  : 'Tier-1 remains available without internet',
              color: hasCellular
                  ? const Color(0xFF4CAF50)
                  : hasWifi
                      ? const Color(0xFFFF9800)
                      : cs.error,
            ),
            const SizedBox(height: 6),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              secondary: Icon(
                Icons.swap_horiz_rounded,
                color: _route.preferCellular ? cs.primary : cs.onSurfaceVariant,
              ),
              title: const Text('Prefer mobile data for cloud'),
              subtitle: Text(_route.lastMessage),
              value: _route.preferCellular,
              onChanged: (value) {
                Get.find<ConnectivityService>()
                    .setPreferCellularForCloud(value);
              },
            ),
            _NetRow(
              icon: Icons.route_rounded,
              label: 'Cloud route',
              value: cloudRouteValue,
              detail: _route.preferCellular
                  ? 'Cloud HTTP uses Android cellular Network when available'
                  : 'Cloud HTTP uses Android default route',
              color: _route.cellularReady
                  ? const Color(0xFF4CAF50)
                  : _route.preferCellular
                      ? const Color(0xFFFF9800)
                      : cs.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            _NetRow(
              icon: Icons.health_and_safety_rounded,
              label: 'Backend',
              value: backendValue,
              detail: backendDetail,
              color: health?.reachable == true
                  ? const Color(0xFF4CAF50)
                  : health == null
                      ? cs.primary
                      : cs.error,
            ),
            const SizedBox(height: 6),
            const _NetRow(
              icon: Icons.lock_clock_rounded,
              label: 'Cloud policy',
              value: 'Triggered snapshots only',
              detail: 'No continuous frame streaming to cloud',
              color: Color(0xFF607D8B),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetRow extends StatelessWidget {
  const _NetRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 4,
                children: [
                  Text(
                    '$label:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
