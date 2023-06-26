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

  /// This is called for each link (visual connection between cells).
  void paint(
    /// Paint to be used for drawing all links
    Paint paint,

    /// Canvas upon which to paint
    Canvas canvas,

    /// Size of canvas, in dpi
    Size size,

    /// Link in question. [a] and [b] are centers of items in
    /// pattern lock coordinates.
    ({Offset a, Offset b}) link,

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
    ({Offset a, Offset b}) link,
    ({int height, int width}) dim,
    double itemDim,
    double anim,
  ) {
    paint.strokeWidth = width;
    paint.color = color.withAlpha(
      (color.alpha * anim).toInt(),
    );

    canvas.drawLine(link.a, link.b, paint);
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
    ({Offset a, Offset b}) link,
    ({int height, int width}) dim,
    double itemDim,
    double anim,
  ) {
    paint.strokeWidth = width;
    paint.shader = gradient.createShader(
      isGlobal
          ? (Offset.zero & size).deflate(itemDim / 2)
          : Rect.fromCenter(
              center: (link.a + link.b) / 2,
              width: math.max(
                (link.a.dx - link.b.dx).abs(),
                width,
              ),
              height: math.max(
                (link.a.dy - link.b.dy).abs(),
                width,
              ),
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
    canvas.drawLine(link.a, link.b, paint);
  }
}
