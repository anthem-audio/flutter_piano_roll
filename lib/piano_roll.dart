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
    case 8:
    case 10:
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
            print(startTopKeyValue.value);
          },
          onPointerMove: (e) {
            final keyDelta =
                (e.localPosition.dy - startPixelValue.value) / keyHeight;
            this.setKeyValueAtTop(startTopKeyValue.value - keyDelta);
          },
        ),
        SizedBox(
          width: 1,
        ),
        Text(keyValueAtTop.toStringAsFixed(3)),
      ],
    );
  }
}
