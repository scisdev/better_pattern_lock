part of 'better_pattern_lock.dart';

// We want to win every one-sequence gesture in our constraints,
// so define a custom recognizer that: 1) wins immediately for it's first
// captured pointer; 2) ignores any subsequent pointers; 3) reports position
// of its only pointer to a delegate callback; 4) reports when pointer is gone.
class _EagerPointerPositionReporter extends OneSequenceGestureRecognizer {
  bool hasPointer = false;

  void Function(Offset)? onPointerPosition;
  void Function()? onUp;

  @override
  bool isPointerAllowed(PointerEvent event) {
    return !hasPointer;
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    resolve(GestureDisposition.accepted);
    startTrackingPointer(event.pointer);
  }

  @override
  void startTrackingPointer(int pointer, [Matrix4? transform]) {
    hasPointer = true;
    super.startTrackingPointer(pointer, transform);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent || event is PointerMoveEvent) {
      onPointerPosition?.call(event.position);
      resolve(GestureDisposition.accepted);
    } else if (event is PointerUpEvent) {
      onUp?.call();
      stopTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);
    } else {
      stopTrackingPointer(event.pointer);
      resolve(GestureDisposition.rejected);
    }
  }

  @override
  String get debugDescription => 'position_reporter';

  @override
  void didStopTrackingLastPointer(int pointer) {
    hasPointer = false;
  }
}
