import 'package:better_pattern_lock/better_pattern_lock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PatternLock is fine on its own', (tester) async {
    await tester.pumpWidget(PatternLock(
      width: 5,
      height: 5,
      onEntered: (pattern) {},
      cellBuilder: (ctx, index, anim) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
            color: Color.lerp(Colors.transparent, Colors.blue, anim)!,
            border: Border.all(
              width: 2.0,
              color: Colors.grey,
              strokeAlign: -1.0,
            ),
          ),
        );
      },
      cellActiveArea: const PatternLockCellActiveArea(
        shape: PatternLockCellAreaShape.square,
        units: PatternLockCellAreaUnits.relative,
        dimension: .75,
      ),
      linkageSettings: PatternLockLinkageSettings.distance(2),
    ));
    final containers = find.byType(Container);
    expect(containers, findsNWidgets(25));
  });
}
