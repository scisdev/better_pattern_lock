part of 'better_pattern_lock.dart';

// default cell appearance
Widget _defaultCellBuilder(PatternLockCellActiveArea aa, double anim) {
  OutlinedButton;
  return LayoutBuilder(builder: (ctx, ctrx) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: aa.shape.isCircle
            ? null
            : BorderRadius.all(
                Radius.circular(ctrx.maxHeight / 4.0),
              ),
        shape: aa.shape.isCircle ? BoxShape.circle : BoxShape.rectangle,
        color: Color.lerp(
          Theme.of(ctx).colorScheme.background,
          Theme.of(ctx).colorScheme.secondary,
          anim,
        )!,
        border: Border.all(
          width: 1.0,
          color: Theme.of(ctx).colorScheme.onSurface.withAlpha(0x3f),
          strokeAlign: -1.0,
        ),
      ),
    );
  });
}

PatternLockLinkAppearance _defaultLinkageAppearance(BuildContext context) {
  return PatternLockLinkAppearance(
    color: Theme.of(context).colorScheme.secondary,
    width: 5.0,
  );
}

// utility function to decide if list<int> has (int, int) or invariant in it
bool _patternContainsLink(List<int> pattern, (int, int) link) {
  for (int i = 0; i < pattern.length - 1; i++) {
    final c = pattern[i];
    final n = pattern[i + 1];
    final f = link.$1;
    final s = link.$2;
    if ((c == f && n == s) || (n == f && c == s)) {
      return true;
    }
  }

  return false;
}

// convenience to get current timestamp in ms
int _now() {
  return DateTime.now().millisecondsSinceEpoch;
}
