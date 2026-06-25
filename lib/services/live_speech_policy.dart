/// Decides when live camera descriptions should be spoken.
///
/// The screen can update every analyzed frame, but audio must be calmer:
/// no repeated OCR loops, immediate replacement on major scene change, and
/// bounded repeat reminders for mostly-stable scenes.
class LiveSpeechPolicy {
  LiveSpeechPolicy({
    this.changeCooldown = const Duration(seconds: 3),
    this.repeatCooldown = const Duration(seconds: 12),
    this.sameContentSimilarity = 0.72,
    this.majorChangeSimilarity = 0.30,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Duration changeCooldown;
  final Duration repeatCooldown;
  final double sameContentSimilarity;
  final double majorChangeSimilarity;
  final DateTime Function() _clock;

  String? _lastSpokenNorm;
  DateTime? _lastSpokenAt;

  LiveSpeechDecision decide(String text) {
    final norm = normalize(text);
    if (norm.isEmpty || _isLowValueStatus(norm)) {
      return const LiveSpeechDecision.silent();
    }

    final now = _clock();
    final previous = _lastSpokenNorm;
    final previousAt = _lastSpokenAt;
    if (previous == null || previousAt == null) {
      _markSpoken(norm, now);
      return const LiveSpeechDecision.speak();
    }

    final similarity = jaccard(previous, norm);
    final elapsed = now.difference(previousAt);

    if (similarity >= 0.92) {
      return const LiveSpeechDecision.silent();
    }

    if (similarity >= sameContentSimilarity) {
      if (similarity < 0.92 &&
          elapsed >= changeCooldown &&
          _hasNewMeaningfulWords(previous, norm)) {
        _markSpoken(norm, now);
        return const LiveSpeechDecision.speak();
      }
      if (elapsed < repeatCooldown) {
        return const LiveSpeechDecision.silent();
      }
      _markSpoken(norm, now);
      return const LiveSpeechDecision.speak();
    }

    if (similarity <= majorChangeSimilarity || elapsed >= changeCooldown) {
      _markSpoken(norm, now);
      return const LiveSpeechDecision.speak();
    }

    return const LiveSpeechDecision.silent();
  }

  void reset() {
    _lastSpokenNorm = null;
    _lastSpokenAt = null;
  }

  void _markSpoken(String norm, DateTime now) {
    _lastSpokenNorm = norm;
    _lastSpokenAt = now;
  }

  static bool _isLowValueStatus(String norm) {
    return norm == 'looking around nothing clear detected yet' ||
        norm == 'no text detected yet' ||
        norm == 'no clear text detected yet' ||
        norm == 'no product detected yet' ||
        norm == 'camera is still adjusting' ||
        norm.startsWith('point camera at something');
  }

  static String normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static double jaccard(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    final sa = Set<String>.from(a.split(' ').where((w) => w.length > 1));
    final sb = Set<String>.from(b.split(' ').where((w) => w.length > 1));
    if (sa.isEmpty && sb.isEmpty) return 1.0;
    if (sa.isEmpty || sb.isEmpty) return 0.0;
    return sa.intersection(sb).length / sa.union(sb).length;
  }

  static bool _hasNewMeaningfulWords(String previous, String current) {
    final before = _meaningfulWords(previous);
    final after = _meaningfulWords(current);
    return after.difference(before).isNotEmpty;
  }

  static Set<String> _meaningfulWords(String text) {
    const stopWords = {
      'and',
      'can',
      'see',
      'text',
      'the',
      'this',
      'that',
      'with',
      'your',
    };
    return text
        .split(' ')
        .where((word) => word.length > 2 && !stopWords.contains(word))
        .toSet();
  }
}

class LiveSpeechDecision {
  const LiveSpeechDecision._(this.shouldSpeak);
  const LiveSpeechDecision.silent() : this._(false);
  const LiveSpeechDecision.speak() : this._(true);

  final bool shouldSpeak;
}
