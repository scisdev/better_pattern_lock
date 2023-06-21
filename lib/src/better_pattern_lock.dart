import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'active_area.dart';
part 'custom_layout_delegate.dart';
part 'linkage.dart';
part 'linkage_vis.dart';
part 'position_reporter.dart';
part 'util.dart';

/// A customizable pattern lock.
/// Works with just [width], [height] and [onEntered] callback.
class PatternLock extends StatefulWidget {
  /// Width of pattern lock. In cells.
  final int width;

  /// Height of pattern lock. In cells.
  final int height;

  /// Controls the process of deciding which cells can and cannot connect.
  final PatternLockLinkageSettings linkageSettings;

  /// Animation duration for appearing and disappearing cells and links.
  final Duration animationDuration;

  /// Called for every update. [current] is the sequence so far.
  final void Function(List<int> current)? onUpdate;

  /// Called when pointer is gone. Validation if up to the user.
  final void Function(List<int> result) onEntered;

  /// Optional builder for each of [width] * [height] cells.
  /// [position] is cell's position in the grid,
  /// counting left to right (should consider directionality?),
  /// top to bottom, **_starting from 1_**.
  /// [anim] is the current animation value of this cell
  /// and goes from 0.0 (inactive) to 1.0 (active).
  final Widget Function(
    BuildContext context,
    int position,
    double anim,
  )? cellBuilder;

  /// See [PatternLockCellActiveArea]
  final PatternLockCellActiveArea cellActiveArea;

  /// See [PatternLockLinkAppearance].
  /// If both this and [linkAppearanceBuilder] are null,
  /// then default appearance will be used.
  final PatternLockLinkAppearance? linkAppearance;

  /// This builder allows to define custom link appearance for each link.
  /// If this is defined, [linkAppearance] must be null.
  final PatternLockLinkAppearance Function(
    BuildContext context,
    PatternLockCellLinkage link,
  )? linkAppearanceBuilder;

  /// Whether to do [HapticFeedback] on cell activation.
  final bool enableFeedback;

  /// Curve to use when animating changes.
  final Curve animationCurve;

  const PatternLock({
    Key? key,
    required this.width,
    required this.height,
    required this.onEntered,
    this.animationDuration = const Duration(milliseconds: 250),
    this.cellActiveArea = const PatternLockCellActiveArea(
      dimension: .7,
      units: PatternLockCellAreaUnits.relative,
      shape: PatternLockCellAreaShape.square,
    ),
    this.linkageSettings = const PatternLockLinkageSettings(
      allowRepetitions: false,
      maxLinkDistance: 1,
    ),
    this.cellBuilder,
    this.onUpdate,
    this.linkAppearance,
    this.linkAppearanceBuilder,
    this.enableFeedback = true,
    this.animationCurve = Curves.linear,
  })  : assert(
          width > 0 && height > 0,
          'Both width and height must be not less than 1',
        ),
        assert(
          linkAppearanceBuilder == null || linkAppearance == null,
          'linkAppearance must be null if linkAppearanceBuilder is not null',
        ),
        super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PatternLockState createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock>
    with SingleTickerProviderStateMixin {
  static const Object _linkPainterId = -1;

  // We can be inside of scrollable thus cannot guarantee constant
  // position of lock and depend on sheer pointer positions
  final gk = GlobalKey();
  final testGK = GlobalKey();
  final pattern = <int>[];

  // The whole system works with a single controller, and is optimized to
  // reduce the amount of rebuilds.
  late final controller = AnimationController.unbounded(
    vsync: this,
    duration: widget.animationDuration,
  );

  @override
  void didUpdateWidget(covariant PatternLock oldWidget) {
    if (oldWidget.height != widget.height || oldWidget.width != widget.width) {
      pattern.clear();
      controller.stop();
    }

    if (oldWidget.animationDuration != widget.animationDuration) {
      controller.duration = widget.animationDuration;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: ValueKey('${widget.width}${widget.height}'),
      builder: (_, ctrx) {
        final width = ctrx.maxWidth;
        final height = ctrx.maxHeight;
        final dim = math.min(width / widget.width, height / widget.height);
        _debugCheckHasFiniteDimensions(dim);

        return RawGestureDetector(
          key: gk,
          gestures: <Type, GestureRecognizerFactory>{
            _EagerPointerPositionReporter: GestureRecognizerFactoryWithHandlers<
                _EagerPointerPositionReporter>(
              () => _EagerPointerPositionReporter(),
              (_EagerPointerPositionReporter instance) {
                instance.onPointerPosition = (pos) => onContact(pos, dim);
                instance.onUp = onUp;
              },
            ),
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: dim * widget.width,
            height: dim * widget.height,
            child: CustomMultiChildLayout(
              delegate: _PatternLockCellLayoutDelegate(
                size: (width: widget.width, height: widget.height),
                activeArea: _getItemActiveArea(dim),
                itemDim: dim,
              ),
              children: [
                LayoutId(
                  id: _linkPainterId,
                  child: _LinkPainter(
                    size: (width: widget.width, height: widget.height),
                    appearance: getLinkageAppearance,
                    curve: widget.animationCurve,
                    controller: controller,
                    pattern: pattern,
                    itemDim: dim,
                  ),
                ),
                for (int i = 0; i < widget.width * widget.height; i++)
                  LayoutId(
                    id: i,
                    child: _PatternCellAnimatedBuilder(
                      controller: controller,
                      isActive: pattern.contains(i + 1),
                      builder: (ctx, anim) {
                        final v = widget.animationCurve.transform(anim);
                        return widget.cellBuilder?.call(ctx, i + 1, v) ??
                            _defaultCellBuilder(widget.cellActiveArea, v);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  PatternLockLinkAppearance? getLinkageAppearance(PatternLockCellLinkage link) {
    if (widget.linkAppearanceBuilder != null) {
      return widget.linkAppearanceBuilder!(context, link);
    } else {
      if (widget.linkAppearance != null) {
        return widget.linkAppearance!;
      } else {
        return null;
      }
    }
  }

  double _getItemActiveArea(double itemDim) {
    return widget.cellActiveArea.units.isRelative
        ? itemDim * widget.cellActiveArea.dimension
        : widget.cellActiveArea.dimension;
  }

  // expects local coords within pattern cell [0; cellDim)
  bool _isWithinActivationAreaBounds(({double x, double y}) c, double cellDim) {
    final aa = _getItemActiveArea(cellDim);

    if (widget.cellActiveArea.shape.isCircle) {
      final (dx, dy) = (2.0 * c.x - cellDim, 2.0 * c.y - cellDim);
      return dx * dx + dy * dy <= aa * aa;
    } else {
      final upper = (cellDim + aa) / 2.0;
      final lower = upper - aa;
      return c.x < upper && c.x > lower && c.y < upper && c.y > lower;
    }
  }

  void _debugCheckHasFiniteDimensions(double cellDim) {
    assert(
      cellDim.isFinite,
      '\n\nAt least one dimension should be < infinity.\n\n'
      'Pattern lock grows to be as large as the minimum max incoming constraint.\n'
      'If your layout does require infinite constraints in both directions, '
      'consider wrapping pattern lock in SizedBox or other techniques to '
      'give it finite room (at least in one direction) to fit in.',
    );
  }

  void onContact(Offset position, double cellDim) {
    // It would be fine to simply report pointer position from position
    // reporter in _local_ coordinates, but we cannot guarantee edge-case
    // of when pattern lock has moved (e.g. scrolled) while pointer is still
    // tracked by position reporter. To cover this, we compare global pointer
    // position with global position of pattern lock.

    // find render object (render box) to get its position
    final rb = gk.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) return;
    // pointer position is global, compare apples to apples
    final globalOffset = rb.localToGlobal(Offset.zero);
    final rect = globalOffset & rb.size;
    // see if pointer is within pattern lock bounds.
    if (!rect.contains(position)) return;
    position -= globalOffset;

    final (x, y) = (position.dx ~/ cellDim, position.dy ~/ cellDim);
    // check if pointer is within activation area
    if (!_isWithinActivationAreaBounds(
      (
        x: position.dx - x * cellDim,
        y: position.dy - y * cellDim,
      ),
      cellDim,
    )) return;

    if (pattern.isNotEmpty) {
      // horizontal, vertical, or diagonal skips are never allowed
      final last = pattern.last - 1;
      final (lx, ly) = (last % widget.width, last ~/ widget.width);
      final (dx, dy) = ((x - lx).abs(), (y - ly).abs());
      if (dy == 0 && dx > 1) return;
      if (dx == 0 && dy > 1) return;
      if (dy > 1 && dx > 1 && dy == dx) return;
      final max = widget.linkageSettings.maxLinkDistance;
      if (math.max(dy, dx) > max) return;
    }

    final el = y * widget.width + x + 1;
    if (!pattern.contains(el) ||
        (widget.linkageSettings.allowRepetitions &&
            !_patternContainsLink(pattern, (pattern.last, el)))) {
      // activate cell
      if (widget.enableFeedback) {
        HapticFeedback.selectionClick();
      }
      pattern.add(el);
      widget.onUpdate?.call(pattern);
      controller.forward();
      setState(() {});
    }
  }

  void onUp() {
    if (widget.enableFeedback) {
      HapticFeedback.selectionClick();
    }
    widget.onEntered(pattern);
    pattern.clear();
    controller.reverse();
    setState(() {});
  }
}

// Kind of like ListenableBuilder, but will build child only if internally
// calculated value has changed, and NOT on every listenable tick.
class _PatternCellAnimatedBuilder extends StatefulWidget {
  final bool isActive;
  final AnimationController controller;
  final Widget Function(BuildContext, double) builder;

  const _PatternCellAnimatedBuilder({
    Key? key,
    required this.isActive,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  @override
  State<_PatternCellAnimatedBuilder> createState() =>
      _PatternCellAnimatedBuilderState();
}

class _PatternCellAnimatedBuilderState
    extends State<_PatternCellAnimatedBuilder> {
  late AnimationController controller;

  double value = 0.0; // current value of cell
  int lastTimestamp = 0; // last timestamp of animation

  @override
  void initState() {
    controller = widget.controller;
    controller.addListener(_listener);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _PatternCellAnimatedBuilder oldWidget) {
    if (widget.controller != controller) {
      controller.removeListener(_listener);
      controller = widget.controller;
      controller.addListener(_listener);
    }

    if (oldWidget.isActive != widget.isActive) {
      lastTimestamp = _now();
    }

    if (!controller.isAnimating) {
      value = widget.isActive ? 1.0 : 0.0;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    super.dispose();
  }

  double _getNewAnimationValue() {
    final target = widget.isActive ? 1.0 : 0.0;
    if (value == target) return value;

    if (controller.isCompleted || controller.isDismissed) {
      return target;
    }

    final now = _now();
    final deltaT = now - lastTimestamp;
    lastTimestamp = now;

    final progress = deltaT / controller.duration!.inMilliseconds;
    return widget.isActive ? value + progress : value - progress;
  }

  void _listener() {
    final newValue = _getNewAnimationValue().clamp(0.0, 1.0);
    if (value != newValue) {
      setState(() {
        value = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value);
  }
}
