part of 'better_pattern_lock.dart';

/// Within a pattern cell, there is a background area, where a pointer can
/// move without activating a cell, and there is an active area,
/// where a pointer may activate the cell.
///
/// This enum controls the unit measurement of activation area.
enum PatternLockCellAreaUnits {
  /// Area as a number pixels across an axis.
  /// Cell always has equal width and height.
  pixels,

  /// Area as a fraction of cell's dimension.
  /// Cell always has equal width and height.
  relative,
}

extension PatternLockCellAreaUnitsX on PatternLockCellAreaUnits {
  bool get isPixels => this == PatternLockCellAreaUnits.pixels;
  bool get isRelative => this == PatternLockCellAreaUnits.relative;
}

/// Within a pattern cell, there is a background area, where a pointer can
/// move without activating a cell, and there is an active area,
/// where a pointer may activate the cell.
///
/// This enum controls the general shape of activation area.
enum PatternLockCellAreaShape {
  /// Activation area is a square.
  square,

  /// Activation area is a circle.
  circle,
}

extension PatternLockCellAreaShapeX on PatternLockCellAreaShape {
  bool get isSquare => this == PatternLockCellAreaShape.square;
  bool get isCircle => this == PatternLockCellAreaShape.circle;
}

/// Specify this to customize what counts as
/// `close enough to center of cell` for this cell to be activated.
///
/// See [PatternLockCellAreaUnits] and [PatternLockCellAreaShape].
class PatternLockCellActiveArea {
  final double dimension;
  final PatternLockCellAreaUnits units;
  final PatternLockCellAreaShape shape;

  const PatternLockCellActiveArea({
    required this.dimension,
    required this.units,
    required this.shape,
  })  : assert(dimension >= 0.0),
        assert(
          units == PatternLockCellAreaUnits.relative ? dimension <= 1.0 : true,
          'Relative cell dimension must be <= 1',
        );
}
