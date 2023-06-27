part of 'better_pattern_lock.dart';

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
