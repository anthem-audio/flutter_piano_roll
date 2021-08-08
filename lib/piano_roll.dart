import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_piano_roll/pattern.dart';
import 'package:flutter_piano_roll/piano_roll_grid.dart';
import 'package:flutter_piano_roll/timeline.dart';
import 'package:provider/provider.dart';

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

class _PianoRollContent extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pattern = context.watch<Pattern>();

    final footerHeight = useState<double>(61);
    final pianoControlWidth = useState<double>(103);
    final keyValueAtTop = useState<double>(64);
    final keyHeight = useState<double>(20);

    final timelineHeight =
        pattern.timeSignatureChanges.length > 0 ? 42.0 : 21.0;

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
                      height: timelineHeight + 1,
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
                child: Padding(
                  padding: EdgeInsets.fromLTRB(1, 1, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: timelineHeight,
                        child: Timeline(
                          pattern: pattern,
                        ),
                      ),
                      Expanded(
                        child: PianoRollGrid(
                          keyHeight: keyHeight.value,
                          keyValueAtTop: keyValueAtTop.value,
                        ),
                      ),
                    ],
                  ),
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
