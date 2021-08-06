import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'globals.dart';
import 'helpers.dart';

final _timelineKey = GlobalKey();

class Timeline extends HookWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var timeView = context.watch<TimeView>();

    final startPixelValue = useRef(-1.0);
    final startTimeViewStartValue = useRef(-1.0);
    final startTimeViewEndValue = useRef(-1.0);

    return Listener(
      key: _timelineKey,
      onPointerDown: (e) {
        startPixelValue.value = e.localPosition.dx;
        startTimeViewStartValue.value = timeView.start;
        startTimeViewEndValue.value = timeView.end;
      },
      onPointerMove: (e) {
        if (!keyboardModifiers.alt) {
          final viewWidth = _timelineKey.currentContext?.size?.width;
          if (viewWidth == null) return;
          print(viewWidth);

          var pixelsPerTick = viewWidth / (timeView.end - timeView.start);
          final tickDelta =
              (e.localPosition.dx - startPixelValue.value) / pixelsPerTick;
          timeView.setStart(startTimeViewStartValue.value - tickDelta);
          timeView.setEnd(startTimeViewEndValue.value - tickDelta);
        } else {
          final oldSize = startTimeViewEndValue.value - startTimeViewStartValue.value;
          final newSize = oldSize * pow(2, 0.01 * (e.localPosition.dx - startPixelValue.value));
          final delta = newSize - oldSize;
          timeView.setStart(startTimeViewStartValue.value + delta * 0.5);
          timeView.setEnd(startTimeViewEndValue.value - delta * 0.5);
        }
      },
      child: Container(
        child: Container(
          color: Color(0xFFFFFFFF).withOpacity(0.12),
          child: Center(child: Text('${timeView.start} - ${timeView.end}')),
        ),
      ),
    );
  }
}
