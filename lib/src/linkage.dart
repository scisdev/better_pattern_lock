part of 'better_pattern_lock.dart';

/// Controls the process of deciding which cells can and cannot connect.
class PatternLockLinkageSettings {
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
  /// Horizontal, vertical, or diagonal skips are never allowed.
  final int maxLinkDistance;

  /// Whether the already activated pattern cell can be activated again from
  /// the last activated cell. Cycles (repeated connections from activated cell
  /// to another activated cell) are never allowed.
  final bool allowRepetitions;

  const PatternLockLinkageSettings({
    this.maxLinkDistance = 1,
    this.allowRepetitions = false,
  }) : assert(maxLinkDistance > 0);
}

/// Linkage between pattern lock cells.
/// [from] and [to] are from 1 to [PatternLock.width] * [PatternLock.height].
///
/// There are convenience methods to get row
/// and column numbers (counting from 0 in this case!) of [from] and [to].
class PatternLockCellLinkage {
  /// Start of this linkage.
  /// Goes from 1 to [PatternLock.width] * [PatternLock.height].
  final int from;

  /// End of this linkage.
  /// Goes from 1 to [PatternLock.width] * [PatternLock.height].
  final int to;

  /// Convenience method to get row number the start of this linkage is in.
  ///
  /// Notice that rows and columns count from 0, unlike cells,
  /// which count from 1.
  int fromRow(int lockWidth) {
    return (from - 1) ~/ lockWidth;
  }

  /// Convenience method to get column number the start of this linkage is in.
  ///
  /// Notice that rows and columns count from 0, unlike cells,
  /// which count from 1.
  int fromColumn(int lockWidth) {
    return (from - 1) % lockWidth;
  }

  /// Convenience method to get row number the end of this linkage is in.
  ///
  /// Notice that rows and columns count from 0, unlike cells,
  /// which count from 1.
  int toRow(int lockWidth) {
    return (to - 1) ~/ lockWidth;
  }

  /// Convenience method to get column number the end of this linkage is in.
  ///
  /// Notice that rows and columns count from 0, unlike cells,
  /// which count from 1.
  int toColumn(int lockWidth) {
    return (to - 1) % lockWidth;
  }

  PatternLockCellLinkage({
    required this.from,
    required this.to,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternLockCellLinkage &&
          runtimeType == other.runtimeType &&
          ((from == other.from && to == other.to) ||
              (from == other.to && to == other.from));

  @override
  int get hashCode => from.hashCode ^ to.hashCode;
}

// Info about a linkage
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
