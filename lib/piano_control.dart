import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_piano_roll/helpers.dart';

import 'globals.dart';

class DragInfo {
  double startX;
  double startY;

  DragInfo({required this.startX, required this.startY});
}

typedef ValueSetter<T> = void Function(T value);

// TODO: rewrite with custom layout

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

    return Row(
      children: [
        Listener(
          onPointerDown: (e) {
            startPixelValue.value = e.localPosition.dy;
            startTopKeyValue.value = keyValueAtTop;
            startKeyHeightValue.value = keyHeight;
          },
          onPointerMove: (e) {
            if (!keyboardModifiers.alt) {
              final keyDelta =
                  (e.localPosition.dy - startPixelValue.value) / keyHeight;
              setKeyValueAtTop(startTopKeyValue.value + keyDelta);
            } else {
              setKeyHeight((startKeyHeightValue.value +
                      (e.localPosition.dy - startPixelValue.value) / 3)
                  .clamp(4, 50));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(1)),
              color: const Color(0xFFFFFFFF).withOpacity(0.12),
            ),
            width: 39,
          ),
        ),
        const SizedBox(width: 1),
        Expanded(
          child: Container(
            child: Stack(
              children: (() {
                var whiteKeys = <Widget>[];
                var blackKeys = <Widget>[];
                double keyPosAccumulator = keyValueToPixels(
                    keyValue: 0,
                    keyValueAtTop: keyValueAtTop,
                    keyHeight: keyHeight);
                for (var i = 0; i <= 87; i++) {
                  if (getKeyType(i) == KeyType.white) {
                    var notchType = getNotchType(i);
                    var hasTopNotch = notchType == NotchType.above ||
                        notchType == NotchType.both;

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

                  keyPosAccumulator -= keyHeight;
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
        notchType == NotchType.both ? keyHeight * 2 : keyHeight * 1.5;
    var hasTopNotch =
        notchType == NotchType.both || notchType == NotchType.above;
    var hasBottomNotch =
        notchType == NotchType.both || notchType == NotchType.below;

    // 41 / 22

    return GestureDetector(
        onTap: () {
          print(keyNumber);
        },
        child: SizedBox(
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
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(1),
                            bottomLeft: Radius.circular(1),
                          ),
                          color: const Color(0xFFFFFFFF).withOpacity(0.6),
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
                    topRight: const Radius.circular(1),
                    bottomRight: const Radius.circular(1),
                  ),
                  color: const Color(0xFFFFFFFF).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ));
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
        borderRadius: const BorderRadius.all(Radius.circular(1)),
        color: const Color(0xFFFFFFFF).withOpacity(0.07),
      ),
      height: keyHeight - 1,
    );
  }
}
