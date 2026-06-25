import 'dart:async';
import 'dart:math';

import '../domain/models.dart';

/// Simulates the Seekr wearable.
///
/// In production this would be a real WiFi socket / platform-channel
/// EventChannel data source — but it would sit behind THIS SAME interface,
/// so the rest of the app never changes when the transport changes
/// (clip-on today, glasses tomorrow). That decoupling is the whole point.
class DeviceService {
  final Random _rand = Random();
  Timer? _timer;

  final StreamController<double> _distanceController =
      StreamController<double>.broadcast();
  final StreamController<DeviceConnectionState> _connectionController =
      StreamController<DeviceConnectionState>.broadcast();

  Stream<double> get distanceStream => _distanceController.stream;
  Stream<DeviceConnectionState> get connectionStream =>
      _connectionController.stream;

  double _lastDistance = 4.0;

  /// Simulated pairing handshake, then a steady stream of distance readings.
  Future<void> connect() async {
    _connectionController.add(DeviceConnectionState.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _connectionController.add(DeviceConnectionState.connected);
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      // Random walk between ~0.4 m and ~5 m, occasionally dipping close
      // so the obstacle alert (and its cooldown) is visible in the demo.
      final delta = (_rand.nextDouble() - 0.5) * 1.6;
      // .clamp() on a double returns `num`, so .toDouble() keeps the field typed.
      _lastDistance = (_lastDistance + delta).clamp(0.4, 5.0).toDouble();
      _distanceController.add(double.parse(_lastDistance.toStringAsFixed(1)));
    });
  }

  void dispose() {
    _timer?.cancel();
    _distanceController.close();
    _connectionController.close();
  }
}
