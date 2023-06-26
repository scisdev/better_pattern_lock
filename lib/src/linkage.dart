part of 'better_pattern_lock.dart';

/// Controls the process of deciding which cells can and cannot connect.
///
/// Implement this interface to create custom linking behaviours.
abstract class PatternLockLinkageSettings {
  const PatternLockLinkageSettings();

  /// Convenience method to create [DistanceBasedPatternLockLinkageSettings].
  factory PatternLockLinkageSettings.distance(int distance) {
    return DistanceBasedPatternLockLinkageSettings(
      allowRepetitions: false,
      maxLinkDistance: distance,
    );
  }

  /// Convenience to check if [link] is in [pattern], since
  /// links are bidirectional.
  bool patternContainsLink(List<int> pattern, (int, int) link) {
    for (int i = 0; i < pattern.length - 1; i++) {
      final c = pattern[i];
      final n = pattern[i + 1];
      final f = link.$1;
      final s = link.$2;
      if ((c == f && n == s) || (n == f && c == s)) {
        return true;
      }
    }

    return false;
  }

  /// If this returns true, [cell] will be added to [currentPattern].
  bool canConnect(
    /// size of pattern lock
    ({int width, int height}) dim,

    /// current pattern
    List<int> pattern,

    /// cell to be considered
    int cell,
  );
}

/// An implementation of [PatternLockLinkageSettings]
/// based on distance between cells.
///
/// Horizontal, vertical, or diagonal skips are never allowed
/// for this implementation.
class DistanceBasedPatternLockLinkageSettings
    extends PatternLockLinkageSettings {
  /// Controls how far the current pattern cell can be from the last
  /// activated cell for current cell to be activated.
  ///
  /// Think of this in terms of how a knight moves in chess.
  /// This integer controls the length of the longer side of knight's movement
  /// that is considered `okay`.
  ///
  /// Let dx be x-axis difference in cell coordinates;
  /// Let dy be y-axis difference in cell coordinates;
  ///
  /// Then allowed cell coordinates are given by:
  /// math.max(dy, dx) <= `maxLinkDistance`.
  ///
  /// `maxLinkDistance` = 1 allows movement in
  /// only 8 directions to adjacent cells,
  ///
  /// `maxLinkDistance` = 2 allows movement to all adjacent
  /// cells *and* like a knight in chess, and so on
  ///
  /// Horizontal, vertical, or diagonal skips are never allowed
  /// for this implementation.
  final int maxLinkDistance;

  /// Whether the already activated pattern cell can be activated again from
  /// the last activated cell.
  final bool allowRepetitions;

  const DistanceBasedPatternLockLinkageSettings({
    required this.maxLinkDistance,
    required this.allowRepetitions,
  }) : assert(maxLinkDistance > 0);

  @override
  bool canConnect(
    ({int width, int height}) dim,
    List<int> pattern,
    int cell,
  ) {
    if (pattern.isEmpty) return true;

    final last = pattern.last;
    final (x, y) = (cell % dim.width, cell ~/ dim.width);
    final (lx, ly) = (last % dim.width, last ~/ dim.width);
    final (dx, dy) = ((x - lx).abs(), (y - ly).abs());
    if (dy == 0 && dx > 1) return false;
    if (dx == 0 && dy > 1) return false;
    if (dy > 1 && dx > 1 && dy == dx) return false;
    if (math.max(dy, dx) > maxLinkDistance) return false;
    if (allowRepetitions) {
      return !patternContainsLink(pattern, (last, cell));
    } else {
      return !pattern.contains(cell);
    }
  }
}

/// Linkage between pattern lock cells.
class PatternLockCellLinkage {
  /// Start (or end) of this linkage.
  final int a;

  /// End (or start) of this linkage.
  final int b;

  PatternLockCellLinkage({
    required this.a,
    required this.b,
  });

  /// Linkage is bidirectional. So we make comparisons bidirectional too.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternLockCellLinkage &&
          runtimeType == other.runtimeType &&
          ((a == other.a && b == other.b) || (a == other.b && b == other.a));

  @override
  int get hashCode => b ^ a;
}

// Internal-use info about a linkage
class _LinkageInfo {
  // last updated timestamp
  final int timestamp;

  // last value
  final double value;

  // direction. false if we disappear, true if we appear
  final bool direction;

  _LinkageInfo({
    required this.timestamp,
    required this.value,
    required this.direction,
  });
}
