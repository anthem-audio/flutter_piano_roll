import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_piano_roll/pattern.dart';
import 'package:provider/provider.dart';

import 'globals.dart';
import 'helpers.dart';

final _timelineKey = GlobalKey();

class Timeline extends HookWidget {
  const Timeline({Key? key, required this.pattern}) : super(key: key);

  final Pattern pattern;

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

          var pixelsPerTick = viewWidth / (timeView.end - timeView.start);
          final tickDelta =
              (e.localPosition.dx - startPixelValue.value) / pixelsPerTick;
          timeView.setStart(startTimeViewStartValue.value - tickDelta);
          timeView.setEnd(startTimeViewEndValue.value - tickDelta);
        } else {
          final oldSize =
              startTimeViewEndValue.value - startTimeViewStartValue.value;
          final newSize = oldSize *
              pow(2, 0.01 * (startPixelValue.value - e.localPosition.dx));
          final delta = newSize - oldSize;
          timeView.setStart(startTimeViewStartValue.value - delta * 0.5);
          timeView.setEnd(startTimeViewEndValue.value + delta * 0.5);
        }
      },
      child: Container(
        color: Color(0xFFFFFFFF).withOpacity(0.12),
        child: ClipRect(
          child: CustomPaint(
            painter: TimelinePainter(
              timeViewStart: timeView.start,
              timeViewEnd: timeView.end,
              pattern: pattern,
            ),
          ),
        ),
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  TimelinePainter(
      {required this.timeViewStart,
      required this.timeViewEnd,
      required this.pattern});

  final double timeViewStart;
  final double timeViewEnd;
  final Pattern pattern;

  @override
  void paint(Canvas canvas, Size size) {
    var divisionChanges = getDivisionChanges(
      viewWidthInPixels: size.width,
      minPixelsPerSection: 5,
      snap: BarSnap(),
      defaultTimeSignature: pattern.baseTimeSignature,
      timeSignatureChanges: pattern.timeSignatureChanges,
      ticksPerQuarter: pattern.ticksPerBeat,
      timeViewStart: timeViewStart,
      timeViewEnd: timeViewEnd,
    );

    var i = 0;
    var timePtr =
        (timeViewStart / divisionChanges[0].divisionRenderSize).floor() *
            divisionChanges[0].divisionRenderSize;
    var barNumber = divisionChanges[0].startLabel;
    if (timePtr < 0) {
      barNumber += (timePtr /
              (divisionChanges[0].divisionRenderSize /
                  divisionChanges[0].distanceBetween))
          .floor();
    }

    while (timePtr < timeViewEnd) {
      // This shouldn't happen, but safety first
      if (i >= divisionChanges.length) break;

      var thisDivision = divisionChanges[i];
      var nextDivisionStart = 0x7FFFFFFFFFFFFFFF; // int max

      if (i < divisionChanges.length - 1)
        nextDivisionStart = divisionChanges[i + 1].offset;

      if (timePtr >= nextDivisionStart) {
        timePtr = nextDivisionStart;
        barNumber = divisionChanges[i + 1].startLabel;
        i++;
        continue;
      }

      while (timePtr < nextDivisionStart && timePtr < timeViewEnd) {
        var x = timeToPixels(
            timeViewStart: timeViewStart,
            timeViewEnd: timeViewEnd,
            viewPixelWidth: size.width,
            time: timePtr.toDouble());

        TextSpan span = new TextSpan(
            style: new TextStyle(color: Color(0xFFFFFFFF).withOpacity(0.6)),
            text: barNumber.toString());
        TextPainter textPainter = new TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        textPainter.layout();
        // TODO: replace height constant
        textPainter.paint(
            canvas, new Offset(x, (21 - textPainter.size.height) / 2));

        timePtr += thisDivision.divisionRenderSize;
        barNumber += thisDivision.distanceBetween;
      }

      i++;
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return oldDelegate.timeViewStart != this.timeViewStart ||
        oldDelegate.timeViewEnd != this.timeViewEnd;
  }

  @override
  bool shouldRebuildSemantics(TimelinePainter oldDelegate) => false;
}
