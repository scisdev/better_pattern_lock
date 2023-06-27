part of 'better_pattern_lock.dart';

/// Controls the process of deciding which cells can and cannot connect.
///
/// Implement this interface to create custom linking behaviours.
abstract class PatternLockLinkageConfig {
  const PatternLockLinkageConfig();

  /// Convenience method to create [DistanceBasedPatternLockLinkageConfig].
  factory PatternLockLinkageConfig.distance(int distance) {
    return DistanceBasedPatternLockLinkageConfig(
      allowRepetitions: false,
      maxLinkDistance: distance,
    );
  }

  /// Convenience method to create
  /// [LengthLimitingDistanceBasedPatternLockLinkageConfig].
  factory PatternLockLinkageConfig.length(int maxLength) {
    return LengthLimitingDistanceBasedPatternLockLinkageConfig(
      maxLength,
      allowRepetitions: false,
      maxLinkDistance: 1,
    );
  }

  /// Convenience method to create
  /// [LengthLimitingDistanceBasedPatternLockLinkageConfig].
  factory PatternLockLinkageConfig.lengthAndDistance(
    int maxLength,
    int distance,
  ) {
    return LengthLimitingDistanceBasedPatternLockLinkageConfig(
      maxLength,
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

/// An implementation of [PatternLockLinkageConfig]
/// based on distance between cells.
///
/// Horizontal, vertical, or diagonal skips are never allowed
/// for this implementation.
class DistanceBasedPatternLockLinkageConfig extends PatternLockLinkageConfig {
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

  const DistanceBasedPatternLockLinkageConfig({
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

/// Extension of [PatternLockLinkageConfig] to also take
/// pattern length into account.
class LengthLimitingDistanceBasedPatternLockLinkageConfig
    extends DistanceBasedPatternLockLinkageConfig {
  /// Max length of pattern.
  final int maxLength;

  LengthLimitingDistanceBasedPatternLockLinkageConfig(
    this.maxLength, {
    required super.maxLinkDistance,
    required super.allowRepetitions,
  });

  @override
  bool canConnect(({int height, int width}) dim, List<int> pattern, int cell) {
    return super.canConnect(dim, pattern, cell) && pattern.length < maxLength;
  }
}
