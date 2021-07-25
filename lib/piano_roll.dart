import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_piano_roll/timeline.dart';

import './piano_control.dart';

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
                      child: PianoControl(
                        keyValueAtTop: keyValueAtTop.value,
                        keyHeight: keyHeight.value,
                        setKeyValueAtTop: (value) {
                          keyValueAtTop.value = value;
                        },
                        setKeyHeight: (value) {
                          keyHeight.value = value;
                        },
                      ),
                    ),
                    SizedBox(height: 1),
                  ],
                ),
              ),
              // Timeline and main paino roll render area
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 22,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(1, 1, 0, 0),
                        child: Timeline(),
                      ),
                    )
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
