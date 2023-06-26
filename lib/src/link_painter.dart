part of 'better_pattern_lock.dart';

/// Painter for each link in pattern lock.
abstract class PatternLockLinkPainter {
  const PatternLockLinkPainter();

  /// Convenience to create a [PatternLockLinkColorPainter].
  factory PatternLockLinkPainter.color({
    required Color color,
    required double width,
  }) {
    return PatternLockLinkColorPainter(
      color: color,
      width: width,
    );
  }

  /// Convenience to create a [PatternLockLinkGradientPainter].
  factory PatternLockLinkPainter.gradient({
    required Gradient gradient,
    required double width,
    bool isGlobal = true,
  }) {
    return PatternLockLinkGradientPainter(
      gradient: gradient,
      width: width,
      isGlobal: isGlobal,
    );
  }

  /// Convenience to get coords of centers of [link] within pattern lock dims
  (Offset, Offset) getLinkCoords(
    PatternLockCellLinkage link,
    double itemDim,
    int lockWidth,
  ) {
    final row1 = link.a % lockWidth;
    final col1 = link.a ~/ lockWidth;
    final row2 = link.b % lockWidth;
    final col2 = link.b ~/ lockWidth;

    final start = Offset((col1 + .5) * itemDim, (row1 + .5) * itemDim);
    final end = Offset((col2 + .5) * itemDim, (row2 + .5) * itemDim);
    return (start, end);
  }

  /// This is called for each link (visual connection between cells).
  void paint(
    /// Paint to be used for drawing all links
    Paint paint,

    /// Canvas upon which to paint
    Canvas canvas,

    /// Size of canvas, in dpi
    Size size,

    /// Link in question
    PatternLockCellLinkage link,

    /// Dimensions of pattern lock in items
    ({int height, int width}) dim,

    /// Dimension of each cell in pattern lock, in dpi
    double itemDim,

    /// 0 for `gone`, 1 for `fully visible`.
    /// Rate of change depends on [PatternLock.animationDuration].
    double anim,
  );
}

/// Paints link with solid color.
class PatternLockLinkColorPainter extends PatternLockLinkPainter {
  /// Color of link.
  final Color color;

  /// Width of link.
  final double width;

  const PatternLockLinkColorPainter({
    required this.color,
    required this.width,
  });

  @override
  void paint(
    Paint paint,
    Canvas canvas,
    Size size,
    PatternLockCellLinkage link,
    ({int height, int width}) dim,
    double itemDim,
    double anim,
  ) {
    paint.strokeWidth = width;
    paint.color = color.withAlpha(
      (color.alpha * anim).toInt(),
    );

    final (start, end) = getLinkCoords(link, itemDim, dim.width);
    canvas.drawLine(start, end, paint);
  }
}

/// Paints link with a gradient.
class PatternLockLinkGradientPainter extends PatternLockLinkPainter {
  /// Width of link.
  final double width;

  /// Gradient to apply.
  final Gradient gradient;

  /// If true, gradient's top-left corner is center of first item,
  /// bottom-right corner is center of last item.
  ///
  /// If false, each link gets its own gradient within its bounds.
  final bool isGlobal;

  const PatternLockLinkGradientPainter({
    required this.width,
    required this.gradient,
    required this.isGlobal,
  });

  @override
  void paint(
    Paint paint,
    Canvas canvas,
    Size size,
    PatternLockCellLinkage link,
    ({int height, int width}) dim,
    double itemDim,
    double anim,
  ) {
    final (start, end) = getLinkCoords(link, itemDim, dim.width);

    paint.shader = gradient.createShader(
      isGlobal
          ? (Offset.zero & size).deflate(itemDim / 2)
          : Rect.fromCenter(
              center: (start + end) / 2,
              width: start.dx == end.dx ? width : itemDim,
              height: start.dy == end.dy ? width : itemDim,
            ),
    );
    // apply fading with color filter.
    // This is identity filter but alpha channel ranges from 0 to 1.
    paint.colorFilter = ColorFilter.matrix(<double>[
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      anim,
      0,
    ]);
    canvas.drawLine(start, end, paint);
  }
}
