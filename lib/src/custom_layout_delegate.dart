part of 'better_pattern_lock.dart';

// We don't use stack because it requires directionality and does more than
// is necessary in this case. Just use CustomMultiChildLayout to position
// children and don't bother with much else.
class _PatternLockCellLayoutDelegate extends MultiChildLayoutDelegate {
  final ({int width, int height}) size;
  final double itemDim;
  final double activeArea;

  _PatternLockCellLayoutDelegate({
    required this.size,
    required this.itemDim,
    required this.activeArea,
  });

  @override
  void performLayout(Size size) {
    // layout lines painter
    layoutChild(_PatternLockState._linkPainterId, BoxConstraints.tight(size));

    // layout actual pattern cells
    for (int y = 0; y < this.size.height; y++) {
      for (int x = 0; x < this.size.width; x++) {
        final i = y * this.size.width + x;
        final leftOffset = itemDim * (x + .5) - activeArea / 2.0;
        final topOffset = itemDim * (y + .5) - activeArea / 2.0;
        positionChild(i, Offset(leftOffset, topOffset));
        layoutChild(i, BoxConstraints.tight(Size.square(activeArea)));
      }
    }
  }

  @override
  bool shouldRelayout(covariant _PatternLockCellLayoutDelegate old) {
    return old.size != size ||
        old.itemDim != itemDim ||
        old.activeArea != activeArea;
  }
}
