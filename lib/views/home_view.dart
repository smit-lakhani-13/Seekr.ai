import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';

import '../controllers/seekr_controller.dart';
import '../domain/models.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ConnectionCard(c: c),
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
              Expanded(child: _SpokenLog(c: c)),
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = c.activeMode.value;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _modes.map((m) {
          final selected = active == m;
          return Semantics(
            button: true,
            selected: selected,
            label: '${m.label} mode. ${m.description}',
            child: ChoiceChip(
              label: Text(m.label),
              selected: selected,
              onSelected: (_) {
                c.selectMode(m);
                SemanticsService.announce(
                    '${m.label} activated', TextDirection.ltr);
              },
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
            leading:
                Icon(isSpeaking ? Icons.volume_up : Icons.volume_off),
            title: Text(speaking ?? 'Silent'),
            subtitle: const Text('Now speaking'),
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
    return Obx(() {
      if (c.spokenLog.isEmpty) {
        return const Center(
          child: Text('Spoken announcements will appear here.'),
        );
      }
      return ListView.separated(
        itemCount: c.spokenLog.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => ListTile(
          dense: true,
          leading: const Icon(Icons.record_voice_over),
          title: Text(c.spokenLog[i]),
        ),
      );
    });
  }
}
