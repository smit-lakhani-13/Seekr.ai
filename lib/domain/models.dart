// Pure domain models — no Flutter imports, so they're trivially unit-testable.

enum SeekrMode {
  none,
  textRecognition,
  sceneDetection,
  depthObstacle,
  supermarket
}

extension SeekrModeX on SeekrMode {
  String get label {
    switch (this) {
      case SeekrMode.none:
        return 'No mode';
      case SeekrMode.textRecognition:
        return 'Text Recognition';
      case SeekrMode.sceneDetection:
        return 'Scene Detection';
      case SeekrMode.depthObstacle:
        return 'Depth & Obstacle';
      case SeekrMode.supermarket:
        return 'Supermarket';
    }
  }

  String get description {
    switch (this) {
      case SeekrMode.none:
        return 'Select a mode to begin.';
      case SeekrMode.textRecognition:
        return 'Reads text from signs, menus and labels.';
      case SeekrMode.sceneDetection:
        return 'Describes your surroundings.';
      case SeekrMode.depthObstacle:
        return 'Warns about obstacles ahead.';
      case SeekrMode.supermarket:
        return 'Identifies aisles and products.';
    }
  }
}

/// One shared audio output. Safety alerts jump the queue and interrupt;
/// descriptive output queues behind them.
enum AudioPriority { safety, normal }

class Utterance {
  final String text;
  final AudioPriority priority;
  const Utterance(this.text, this.priority);
}

/// Named to avoid clashing with Flutter's framework `ConnectionState`.
enum DeviceConnectionState { disconnected, connecting, connected }
