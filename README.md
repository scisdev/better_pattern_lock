# Better Pattern Lock

---

**_Well, 'better' is a subjective word. 
This one allows for a lot more customization._**

## It's a pattern lock

Just like in your old Samsung device but this one's 
with Flutter and is much more customizable.

![](https://github.com/scisdev/better_pattern_lock/blob/master/media/demo.webm)

You can hide content behind a visual password. 
You can use it as a kind of spoiler alert or a content gate. 
You can use it in a login flow. Etc!

## Usage

It's a widget that sizes itself to the smallest 
of given constraints (like `BoxFit.contain`).
This means you can also use it in scroll views.

```dart
YourScreen(
  child: PatternLock(
    width: 4,
    height: 4,
    onEntered: (pattern) {},
  ),
);
```



## Customization

All possible customization parameters are listed below:

```dart
PatternLock(
  width: 4,
  height: 4,
  onEntered: (pattern) {
    print('finished with $pattern');
  },
  onUpdate: (pattern) {
    print('current pattern: $pattern');
  },
  cellBuilder: (ctx, index, anim) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.lerp(Colors.transparent, Colors.blue, anim),
        border: Border.all(
          color: Colors.grey,
          width: 3.0,
        ),
      ),
    );
  },
  cellActivationArea: const PatternLockCellActivationArea(
    shape: PatternLockCellAreaShape.circle,
    units: PatternLockCellAreaUnits.relative,
    dimension: .75,
  ),
  linkageSettings: const PatternLockLinkageSettings(
    maxLinkDistance: 2,
    allowRepetitions: false,
  ),
  lineAppearance: const PatternLockLineAppearance(
    color: Colors.blue,
    width: 4.0,
  ),
  animationDuration: const Duration(milliseconds: 550),
  animationCurve: Curves.easeInOutCubic,
  enableFeedback: true,
);
```

Docs within the library provide concrete meanings for all of these.