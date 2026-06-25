/// Monotonic generation gate for live camera analysis.
///
/// If capture N+1 finishes before capture N, only N+1 may update the overlay
/// or speak. Resetting the generation also invalidates late results after the
/// live camera has been closed.
class LiveFrameGate {
  int _nextSequence = 0;
  int _generation = 0;
  int _latestAppliedSequence = 0;

  LiveFrameTicket begin() {
    return LiveFrameTicket(
      generation: _generation,
      sequence: ++_nextSequence,
    );
  }

  bool tryApply(LiveFrameTicket ticket) {
    if (ticket.generation != _generation) return false;
    if (ticket.sequence <= _latestAppliedSequence) return false;
    _latestAppliedSequence = ticket.sequence;
    return true;
  }

  void reset() {
    _generation++;
    _latestAppliedSequence = 0;
  }
}

class LiveFrameTicket {
  const LiveFrameTicket({
    required this.generation,
    required this.sequence,
  });

  final int generation;
  final int sequence;
}
