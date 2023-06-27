part of 'main.dart';

class Variant2 extends StatelessWidget {
  const Variant2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PatternLock(
      width: 10,
      height: 10,
      onEntered: (pattern) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'entered ${pattern.join('-')}',
              ),
            ),
          );
      },
      linkageSettings: PatternLockLinkageSettings.distance(1),
      linkPainter: DashedLineConnector(Theme.of(context).primaryColor),
      drawLineToPointer: false,
      cellBuilder: (ctx, ind, anim) {
        return LayoutBuilder(builder: (ctx, ctrx) {
          final a = ctrx.maxHeight / 4.0;
          final b = a * 2.0;
          return Material(
            type: MaterialType.card,
            color: Colors.transparent,
            elevation: 16.0 * anim,
            animationDuration: Duration.zero,
            borderRadius: BorderRadius.all(
              Radius.circular(a + (b - a) * anim),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(a + (b - a) * anim),
                ),
                color: Color.lerp(
                  Theme.of(ctx).colorScheme.background,
                  Theme.of(ctx).colorScheme.primary,
                  anim,
                )!,
                border: Border.all(
                  width: 1.0,
                  color: Colors.grey,
                  strokeAlign: -1.0,
                ),
              ),
            ),
          );
        });
      },
      cellActiveArea: const PatternLockCellActiveArea(
        shape: PatternLockCellAreaShape.square,
        units: PatternLockCellAreaUnits.relative,
        dimension: .85,
      ),
      animationDuration: const Duration(milliseconds: 350),
    );
  }
}

class DashedLineConnector extends PatternLockLinkPainter {
  static const double _dashLength = 0.0;
  static const double _skipLength = 14.0;
  static const double _strokeWidth = 7.0;

  final Color color;

  DashedLineConnector(this.color);

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
    paint.color = color.withOpacity(anim);
    paint.strokeWidth = _strokeWidth;

    final Offset delta = link.b - link.a;
    final ds = delta.distanceSquared;
    final d = delta.direction;
    final c = math.cos(d);
    final s = math.sin(d);
    final dashOffset = Offset(_dashLength * c, _dashLength * s);
    final skipOffset = Offset(_skipLength * c, _skipLength * s);
    final totalOffset = dashOffset + skipOffset;
    Offset progress = link.a;

    while (true) {
      final dashStart = progress;
      final dashEnd = dashStart + dashOffset;
      if (ds >= (dashEnd - link.a).distanceSquared) {
        canvas.drawLine(dashStart, dashEnd, paint);
      } else {
        canvas.drawLine(dashStart, link.b, paint);
        break;
      }

      final skipStart = dashEnd;
      final skipEnd = skipStart + skipOffset;
      if (ds < (skipEnd - link.a).distanceSquared) {
        break;
      }

      progress += totalOffset;
    }
  }
}
