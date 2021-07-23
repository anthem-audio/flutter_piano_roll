import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PianoRoll extends StatefulWidget {
  const PianoRoll({Key? key}) : super(key: key);

  @override
  _PianoRollState createState() => _PianoRollState();
}

class _PianoRollState extends State<PianoRoll> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Column(
        children: [
          _PianoRollHeader(),
          Expanded(
            child: _PianoRollContent(),
          ),
        ],
      ),
    );
  }
}

class _PianoRollHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF).withOpacity(0.12),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
      ),
      height: 42,
    );
  }
}

double keyValueToPixels({
  required double keyValue,
  required double keyValueAtTop,
  required double viewHeightInPixels,
  required double keyHeight,
}) {
  final keyOffsetFromTop = keyValueAtTop - keyValue;
  return keyOffsetFromTop * keyHeight;
}

double pixelsToKeyValue({
  required double pixelOffsetFromTop,
  required double keyValueAtTop,
  required double keyHeight,
}) {
  final keyOffsetFromTop = pixelOffsetFromTop / keyHeight;
  return keyValueAtTop - keyOffsetFromTop;
}

class _PianoRollContent extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final footerHeight = useState<double>(61);
    final pianoControlWidth = useState<double>(103);
    final keyValueAtTop = useState<double>(64);
    final keyHeight = useState<double>(20);

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Piano control
              SizedBox(
                width: pianoControlWidth.value,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF).withOpacity(0.12),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(1),
                          bottomRight: Radius.circular(1),
                        ),
                      ),
                      height: 22,
                    ),
                    SizedBox(height: 1),
                    Expanded(
                      child: _PianoControl(
                        keyValueAtTop: keyValueAtTop.value,
                        keyHeight: keyHeight.value,
                        setKeyValueAtTop: (value) {
                          keyValueAtTop.value = value;
                        },
                      ),
                    ),
                    SizedBox(height: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Color(0xFFFFFFFF).withOpacity(0.12),
          height: footerHeight.value,
        ),
      ],
    );
  }
}

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

class _PianoControl extends HookWidget {
  const _PianoControl({
    Key? key,
    required this.keyValueAtTop,
    required this.keyHeight,
    required this.setKeyValueAtTop,
  }) : super(key: key);

  final double keyValueAtTop;
  final double keyHeight;
  final ValueSetter<double> setKeyValueAtTop;

  @override
  Widget build(BuildContext context) {
    final startPixelValue = useRef(-1.0);
    final startTopKeyValue = useRef(-1.0);

    return Row(
      children: [
        Listener(
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
          },
          onPointerMove: (e) {
            final keyDelta =
                (e.localPosition.dy - startPixelValue.value) / keyHeight;
            this.setKeyValueAtTop(startTopKeyValue.value - keyDelta);
          },
        ),
        SizedBox(width: 1),
        Expanded(
          child: Container(
            // clipBehavior: Clip.hardEdge,
            child: Stack(
              children: (() {
                var keys = <Widget>[];
                double keyPosAccumulator = -(keyValueAtTop * keyHeight);
                for (var i = 87; i >= 0; i--) {
                  if (getKeyType(i) == KeyType.WHITE) {
                    var notchType = getNotchType(i);
                    var hasTopNotch = notchType == NotchType.ABOVE ||
                        notchType == NotchType.BOTH;

                    keys.add(
                      Positioned(
                        top: keyPosAccumulator -
                            (hasTopNotch ? keyHeight / 2 : 0),
                        left: 0,
                        right: 0,
                        child: _WhiteKey(
                          keyNumber: i,
                        ),
                      ),
                    );
                  } else {
                    keys.add(
                      Positioned(
                        top: keyPosAccumulator,
                        left: 0,
                        right: 23,
                        child: _BlackKey(
                          keyNumber: i,
                        ),
                      ),
                    );
                  }

                  keyPosAccumulator += keyHeight;
                }
                return keys;
              })(),
            ),
          ),
        ),
      ],
    );
  }
}

class _WhiteKey extends HookWidget {
  const _WhiteKey({Key? key, required this.keyNumber}) : super(key: key);

  final int keyNumber;

  @override
  Widget build(BuildContext context) {
    var notchType = getNotchType(keyNumber);
    double widgetHeight = notchType == NotchType.BOTH ? 40 : 30;
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
                SizedBox(height: hasTopNotch ? 10 : 0),
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
                SizedBox(height: hasBottomNotch ? 10 : 0),
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
  const _BlackKey({Key? key, required this.keyNumber}) : super(key: key);

  final int keyNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(1)),
        color: Color(0xFFFFFFFF).withOpacity(0.07),
      ),
      height: 19,
    );
  }
}
