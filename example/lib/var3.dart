part of 'main.dart';

class Variant3 extends StatelessWidget {
  final int x;
  final int y;
  final List<int> colors;

  const Variant3({
    Key? key,
    required this.x,
    required this.y,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PatternLock(
      width: x,
      height: y,
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
      linkageConfig: PatternLockLinkageConfig.distance(3),
      linkPainter: const PatternLockLinkGradientPainter(
        width: 10.0,
        gradient: SweepGradient(
          center: FractionalOffset.center,
          colors: <Color>[
            Color(0xFF4285F4),
            Color(0xFF34A853),
            Color(0xFFFBBC05),
            Color(0xFFEA4335),
            Color(0xFF4285F4),
          ],
          stops: <double>[0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        isGlobal: true,
      ),
      drawLineToPointer: true,
      cellBuilder: (ctx, ind, anim) {
        return Material(
          type: MaterialType.circle,
          color: Colors.transparent,
          elevation: 32.0 * anim,
          animationDuration: Duration.zero,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.lerp(
                Theme.of(ctx).colorScheme.background,
                Color(colors[ind]),
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
      },
      cellActiveArea: const PatternLockCellActiveArea(
        shape: PatternLockCellAreaShape.circle,
        units: PatternLockCellAreaUnits.relative,
        dimension: .75,
      ),
      animationDuration: const Duration(milliseconds: 350),
    );
  }
}
