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
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: const Color(0xFFFFFFFF).withOpacity(0.12),
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
            CustomMultiChildLayout(
              children: pattern.timeSignatureChanges
                  .map(
                    (change) => LayoutId(
                      id: change.offset,
                      child: TimelineLabel(
                          text:
                              "${change.timeSignature.numerator}/${change.timeSignature.denominator}"),
                    ),
                  )
                  .toList(),
              delegate: TimeSignatureLabelLayoutDelegate(
                timeSignatureChanges: pattern.timeSignatureChanges,
                timeViewStart: timeView.start,
                timeViewEnd: timeView.end,
                // viewPixelWidth:
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSignatureLabelLayoutDelegate extends MultiChildLayoutDelegate {
  TimeSignatureLabelLayoutDelegate({
    required this.timeSignatureChanges,
    required this.timeViewStart,
    required this.timeViewEnd,
    // required this.viewPixelWidth,
  });

  List<TimeSignatureChange> timeSignatureChanges;
  double timeViewStart;
  double timeViewEnd;
  // double viewPixelWidth;

  @override
  void performLayout(Size size) {
    for (var change in timeSignatureChanges) {
      layoutChild(
        change.offset,
        BoxConstraints(
          maxWidth: size.width,
          maxHeight: size.height,
        ),
      );

      var x = timeToPixels(
        timeViewStart: timeViewStart,
        timeViewEnd: timeViewEnd,
        viewPixelWidth: size.width,
        time: change.offset.toDouble(),
      );

      positionChild(change.offset, Offset(x, 21));
    }
  }

  @override
  bool shouldRelayout(TimeSignatureLabelLayoutDelegate oldDelegate) {
    // This compares two lists. I have no idea if that makes sense in flutter
    // but we may get a stale layout doing that.
    return oldDelegate.timeViewStart != timeViewStart ||
        oldDelegate.timeViewEnd != timeViewEnd ||
        oldDelegate.timeSignatureChanges != timeSignatureChanges;
  }
}

class TimelineLabel extends HookWidget {
  const TimelineLabel({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: const Color(0xFFFFFFFF).withOpacity(0.6),
          width: 2,
          height: 21,
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withOpacity(0.08),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(3),
            ),
          ),
          child: Text(text),
          padding: const EdgeInsets.only(left: 4, right: 4),
          height: 21,
        ),
      ],
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
      minPixelsPerSection: 32,
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

      if (i < divisionChanges.length - 1) {
        nextDivisionStart = divisionChanges[i + 1].offset;
      }

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

        TextSpan span = TextSpan(
            style: TextStyle(color: const Color(0xFFFFFFFF).withOpacity(0.6)),
            text: barNumber.toString());
        TextPainter textPainter = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        textPainter.layout();
        // TODO: replace height constant
        textPainter.paint(
            canvas, Offset(x, (21 - textPainter.size.height) / 2));

        timePtr += thisDivision.divisionRenderSize;
        barNumber += thisDivision.distanceBetween;
      }

      i++;
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return oldDelegate.timeViewStart != timeViewStart ||
        oldDelegate.timeViewEnd != timeViewEnd;
  }

  @override
  bool shouldRebuildSemantics(TimelinePainter oldDelegate) => false;
}
