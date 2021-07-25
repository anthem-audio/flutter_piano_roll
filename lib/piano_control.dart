import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DragInfo {
  double startX;
  double startY;

  DragInfo({required this.startX, required this.startY});
}

enum KeyType { BLACK, WHITE }
enum NotchType { ABOVE, BELOW, BOTH }

KeyType getKeyType(int key) {
  switch (key % 12) {
    case 1:
    case 4:
    case 6:
    case 9:
    case 11:
      return KeyType.BLACK;
    default:
      return KeyType.WHITE;
  }
}

NotchType getNotchType(int key) {
  final keyTypeBelow = getKeyType(key - 1);
  final keyTypeAbove = getKeyType(key + 1);

  if (keyTypeAbove == KeyType.BLACK && keyTypeBelow == KeyType.WHITE) {
    return NotchType.ABOVE;
  } else if (keyTypeAbove == KeyType.WHITE && keyTypeBelow == KeyType.BLACK) {
    return NotchType.BELOW;
  }

  return NotchType.BOTH;
}

typedef ValueSetter<T> = void Function(T value);

class PianoControl extends HookWidget {
  const PianoControl({
    Key? key,
    required this.keyValueAtTop,
    required this.keyHeight,
    required this.setKeyValueAtTop,
    required this.setKeyHeight,
  }) : super(key: key);

  final double keyValueAtTop;
  final double keyHeight;
  final ValueSetter<double> setKeyValueAtTop;
  final ValueSetter<double> setKeyHeight;

  @override
  Widget build(BuildContext context) {
    final startPixelValue = useRef(-1.0);
    final startTopKeyValue = useRef(-1.0);
    final startKeyHeightValue = useRef(-1.0);

    final isAltPressed = useRef(false);

    return Row(
      children: [
        // This is hacky. Not sure where this should go in a proper app.
        RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (e) {
            isAltPressed.value = e.isAltPressed;
          },
          child: Listener(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(1)),
                color: Color(0xFFFFFFFF).withOpacity(0.12),
              ),
              width: 39,
            ),
            onPointerDown: (e) {
              startPixelValue.value = e.localPosition.dy;
              startTopKeyValue.value = keyValueAtTop;
              startKeyHeightValue.value = keyHeight;
            },
            onPointerMove: (e) {
              if (!isAltPressed.value) {
                final keyDelta =
                    (e.localPosition.dy - startPixelValue.value) / keyHeight;
                this.setKeyValueAtTop(startTopKeyValue.value - keyDelta);
              } else {
                this.setKeyHeight(
                    ((e.localPosition.dy - startPixelValue.value) / 3)
                        .clamp(4, 50));
              }
            },
          ),
        ),
        SizedBox(width: 1),
        Expanded(
          child: Container(
            // clipBehavior: Clip.hardEdge,
            child: Stack(
              children: (() {
                var whiteKeys = <Widget>[];
                var blackKeys = <Widget>[];
                double keyPosAccumulator = -(keyValueAtTop * keyHeight);
                for (var i = 87; i >= 0; i--) {
                  if (getKeyType(i) == KeyType.WHITE) {
                    var notchType = getNotchType(i);
                    var hasTopNotch = notchType == NotchType.ABOVE ||
                        notchType == NotchType.BOTH;

                    whiteKeys.add(
                      Positioned(
                        top: keyPosAccumulator -
                            (hasTopNotch ? keyHeight / 2 : 0),
                        left: 0,
                        right: 0,
                        child: _WhiteKey(
                          keyNumber: i,
                          keyHeight: keyHeight,
                        ),
                      ),
                    );
                  } else {
                    blackKeys.add(
                      Positioned(
                        top: keyPosAccumulator,
                        left: 0,
                        right: 23,
                        child: _BlackKey(
                          keyNumber: i,
                          keyHeight: keyHeight,
                        ),
                      ),
                    );
                  }

                  keyPosAccumulator += keyHeight;
                }

                return whiteKeys + blackKeys;
              })(),
            ),
          ),
        ),
      ],
    );
  }
}

class _WhiteKey extends HookWidget {
  const _WhiteKey({Key? key, required this.keyNumber, required this.keyHeight})
      : super(key: key);

  final int keyNumber;
  final double keyHeight;

  @override
  Widget build(BuildContext context) {
    var notchType = getNotchType(keyNumber);
    double widgetHeight =
        notchType == NotchType.BOTH ? keyHeight * 2 : keyHeight * 1.5;
    var hasTopNotch =
        notchType == NotchType.BOTH || notchType == NotchType.ABOVE;
    var hasBottomNotch =
        notchType == NotchType.BOTH || notchType == NotchType.BELOW;

    // 41 / 22

    return SizedBox(
      height: widgetHeight - 1,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(height: hasTopNotch ? keyHeight * 0.5 : 0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(1),
                        bottomLeft: Radius.circular(1),
                      ),
                      color: Color(0xFFFFFFFF).withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(height: hasBottomNotch ? keyHeight * 0.5 : 0),
              ],
            ),
          ),
          Container(
            width: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(hasTopNotch ? 1 : 0),
                bottomLeft: Radius.circular(hasBottomNotch ? 1 : 0),
                topRight: Radius.circular(1),
                bottomRight: Radius.circular(1),
              ),
              color: Color(0xFFFFFFFF).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlackKey extends HookWidget {
  const _BlackKey({Key? key, required this.keyNumber, required this.keyHeight})
      : super(key: key);

  final int keyNumber;
  final double keyHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(1)),
        color: Color(0xFFFFFFFF).withOpacity(0.07),
      ),
      height: keyHeight - 1,
    );
  }
}
