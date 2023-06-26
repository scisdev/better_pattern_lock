part of 'better_pattern_lock.dart';

// Paints lines between activated cells.
class _LinkPainterWidget extends StatefulWidget {
  final PatternLockLinkPainter painter;
  final List<int> pattern;
  final AnimationController controller;
  final ({int width, int height}) size;
  final double itemDim;
  final Curve curve;

  const _LinkPainterWidget({
    Key? key,
    required this.painter,
    required this.pattern,
    required this.controller,
    required this.size,
    required this.curve,
    required this.itemDim,
  }) : super(key: key);

  @override
  State<_LinkPainterWidget> createState() => _LinkPainterWidgetState();
}

class _LinkPainterWidgetState extends State<_LinkPainterWidget>
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
  void didUpdateWidget(covariant _LinkPainterWidget oldWidget) {
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
        a: widget.pattern[i],
        b: widget.pattern[i + 1],
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

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinkCanvasPainter(
        size: widget.size,
        curve: widget.curve,
        itemDim: widget.itemDim,
        painter: widget.painter,
        connections: connections,
      ),
    );
  }
}

class _LinkCanvasPainter extends CustomPainter {
  final PatternLockLinkPainter painter;
  final HashMap<PatternLockCellLinkage, _LinkageInfo> connections;
  final ({int width, int height}) size;
  final double itemDim;
  final Curve curve;

  _LinkCanvasPainter({
    required this.size,
    required this.curve,
    required this.painter,
    required this.itemDim,
    required this.connections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    for (final conn in connections.entries) {
      painter.paint(
        p,
        canvas,
        size,
        conn.key,
        this.size,
        itemDim,
        curve.transform(conn.value.value),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinkCanvasPainter old) {
    return old.itemDim != itemDim ||
        old.curve != curve ||
        old.painter != painter ||
        old.connections != connections ||
        old.size != size;
  }
}
