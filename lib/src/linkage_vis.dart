part of 'better_pattern_lock.dart';

/// Controls visuals of a line between two connected cells.
class PatternLockLinkAppearance {
  /// The color of the line.
  /// /// If this is not null, then [gradient] must be null.
  final Color? color;

  /// The gradient of the line.
  /// If this is not null, then [color] must be null.
  final PatternLockLinkGradient? gradient;

  /// The width of the line.
  final double width;

  const PatternLockLinkAppearance({
    this.width = 1.0,
    this.color,
    this.gradient,
  })  : assert(width >= 0),
        assert(
            (color != null && gradient == null) ||
                (color == null && gradient != null),
            'One of `color` and `gradient` must be specified, but not both');
}

/// Gradient and a way to apply it.
///
/// You can use one big (global) gradient
/// or separate gradients for each link.
class PatternLockLinkGradient {
  /// Gradient to apply.
  final Gradient gradient;

  /// If true, gradient's top-left corner is center of item 1,
  /// bottom-right corner is center of item [PatternLock.width] * [PatternLock.height].
  ///
  /// If false, each link gets its own gradient.
  final bool isGlobal;

  PatternLockLinkGradient({
    required this.gradient,
    required this.isGlobal,
  });
}

// Paints lines between activated cells.
class _LinkPainter extends StatefulWidget {
  final PatternLockLinkAppearance? Function(
    PatternLockCellLinkage link,
  ) appearance;
  final List<int> pattern;
  final AnimationController controller;
  final ({int width, int height}) size;
  final double itemDim;
  final Curve curve;

  const _LinkPainter({
    Key? key,
    required this.appearance,
    required this.pattern,
    required this.controller,
    required this.size,
    required this.curve,
    required this.itemDim,
  }) : super(key: key);

  @override
  State<_LinkPainter> createState() => _LinkPainterState();
}

class _LinkPainterState extends State<_LinkPainter>
    with TickerProviderStateMixin {
  late AnimationController controller;

  // A map of line connections and their states.
  // Kind of like with a cell state, but this time it's a map, not one value.
  final connections = HashMap<PatternLockCellLinkage, _LinkageInfo>();

  void _listener() {
    if (connections.isEmpty) return;

    if (controller.isDismissed) {
      connections.clear();
      setState(() {});
      return;
    }

    final now = _now();
    final toRemove = <PatternLockCellLinkage>[]; // remove links with value = 0
    for (final c in connections.entries) {
      if (controller.isCompleted) {
        connections[c.key] = _LinkageInfo(
          value: 1.0,
          timestamp: now,
          direction: true,
        );
        continue;
      }

      final deltaT = now - c.value.timestamp;
      final dProgress = deltaT / widget.controller.duration!.inMilliseconds;
      final progress = (c.value.direction
              ? c.value.value + dProgress
              : c.value.value - dProgress)
          .clamp(0.0, 1.0);

      if (progress == 0.0) {
        toRemove.add(c.key);
      } else {
        connections[c.key] = _LinkageInfo(
          value: progress,
          timestamp: now,
          direction: c.value.direction,
        );
      }
    }

    for (final e in toRemove) {
      connections.remove(e);
    }

    setState(() {});
  }

  @override
  void initState() {
    controller = widget.controller;
    controller.addListener(_listener);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void didUpdateWidget(covariant _LinkPainter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != controller) {
      controller.removeListener(_listener);
      controller = widget.controller;
      controller.addListener(_listener);
    }

    if (widget.size != oldWidget.size) {
      this.connections.clear();
      return;
    }

    final connections =
        HashMap<PatternLockCellLinkage, _LinkageInfo>.from(this.connections);
    final now = _now();
    for (int i = 0; i < widget.pattern.length - 1; i++) {
      final link = PatternLockCellLinkage(
        from: widget.pattern[i],
        to: widget.pattern[i + 1],
      );

      this.connections[link] = _LinkageInfo(
        timestamp: now,
        value: this.connections[link]?.value ?? 0.0,
        direction: true,
      );
      connections.remove(link);
    }

    for (final c in connections.entries) {
      this.connections[c.key] = _LinkageInfo(
        timestamp: now,
        value: c.value.value,
        direction: false,
      );
    }
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    connections.clear();
    super.dispose();
  }

  PatternLockLinkAppearance _getAppearance(PatternLockCellLinkage link) {
    return widget.appearance(link) ?? _defaultLinkageAppearance(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinkCanvasPainter(
        size: widget.size,
        curve: widget.curve,
        itemDim: widget.itemDim,
        connections: connections,
        appearance: _getAppearance,
      ),
    );
  }
}

class _LinkCanvasPainter extends CustomPainter {
  final PatternLockLinkAppearance Function(
    PatternLockCellLinkage link,
  ) appearance;
  final HashMap<PatternLockCellLinkage, _LinkageInfo> connections;
  final ({int width, int height}) size;
  final double itemDim;
  final Curve curve;

  _LinkCanvasPainter({
    required this.size,
    required this.curve,
    required this.itemDim,
    required this.appearance,
    required this.connections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    final w = this.size.width;

    for (final conn in connections.entries) {
      final appearance = this.appearance(conn.key);
      final v = conn.value;
      final t = curve.transform(v.value);
      if (t == 0.0) continue;

      final row1 = conn.key.fromRow(w);
      final col1 = conn.key.fromColumn(w);
      final row2 = conn.key.toRow(w);
      final col2 = conn.key.toColumn(w);

      final start = Offset((col1 + .5) * itemDim, (row1 + .5) * itemDim);
      final end = Offset((col2 + .5) * itemDim, (row2 + .5) * itemDim);

      p.strokeWidth = appearance.width;
      if (appearance.color != null) {
        p.color = appearance.color!.withAlpha(
          (appearance.color!.alpha * t).toInt(),
        );
      } else {
        final g = appearance.gradient!;
        p.shader = g.gradient.createShader(
          g.isGlobal
              ? (Offset.zero & size).deflate(itemDim / 2)
              : Rect.fromCenter(
                  center: (start + end) / 2,
                  width: start.dx == end.dx ? appearance.width : itemDim,
                  height: start.dy == end.dy ? appearance.width : itemDim,
                ),
        );
        // apply fading with color filter.
        // This is identity filter but alpha channel ranges from 0 to 1.
        p.colorFilter = ColorFilter.matrix(<double>[
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
          t,
          0,
        ]);
      }

      canvas.drawLine(start, end, p);
    }
  }

  @override
  bool shouldRepaint(covariant _LinkCanvasPainter old) {
    return old.itemDim != itemDim ||
        old.curve != curve ||
        old.appearance != appearance ||
        old.connections != connections ||
        old.size != size;
  }
}
