import 'package:flutter/widgets.dart';
import 'package:flutter_piano_roll/helpers.dart';
import 'package:provider/provider.dart';
import 'package:flutter_piano_roll/pattern.dart';

class PianoRollGrid extends StatelessWidget {
  const PianoRollGrid({
    Key? key,
    required this.keyHeight,
    required this.keyValueAtTop,
  }) : super(key: key);

  final double keyValueAtTop;
  final double keyHeight;

  @override
  Widget build(BuildContext context) {
    var pattern = context.watch<Pattern>();
    var timeView = context.watch<TimeView>();

    return Container(
      child: ClipRect(
        // child: Container(color: Color(0xFF00FF00)),
        child: CustomPaint(
          painter: PianoRollBackgroundPainter(
            keyHeight: keyHeight,
            keyValueAtTop: keyValueAtTop,
            pattern: pattern,
            timeView: timeView,
          ),
        ),
      ),
    );
  }
}

class PianoRollBackgroundPainter extends CustomPainter {
  PianoRollBackgroundPainter({
    required this.keyHeight,
    required this.keyValueAtTop,
    required this.pattern,
    required this.timeView,
  });

  final double keyHeight;
  final double keyValueAtTop;
  final Pattern pattern;
  final TimeView timeView;

  @override
  void paint(Canvas canvas, Size size) {
    var color = Paint();
    color.color = Color(0xFFFFFFFF);

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Color(0xFF000000).withOpacity(0.2),
    );

    // Horizontal lines

    var linePointer = keyHeight - ((keyValueAtTop * keyHeight) % keyHeight);

    while (linePointer < size.height) {
      canvas.drawRect(Rect.fromLTWH(0, linePointer, size.width, 1), color);
      linePointer += keyHeight;
    }

    // Vertical lines

    var divisionChanges = getDivisionChanges(
      viewWidthInPixels: size.width,
      minPixelsPerSection: 5,
      snap: DivisionSnap(division: Division(multiplier: 4, divisor: 1)),
      defaultTimeSignature: pattern.baseTimeSignature,
      timeSignatureChanges: pattern.timeSignatureChanges,
      ticksPerQuarter: pattern.ticksPerBeat,
      timeView: timeView,
    );

    var i = 0;
    // There should always be at least one division change. The first change
    // should always represent the base time signature for the pattern (or the
    // first time signature change, if its position is 0).
    var timePtr =
        (timeView.start / divisionChanges[0].divisionRenderSize).floor() *
            divisionChanges[0].divisionRenderSize;

    while (timePtr < timeView.end) {
      // This shouldn't happen, but safety first
      if (i >= divisionChanges.length) break;

      var thisDivision = divisionChanges[i];
      var nextDivisionStart = 0x7FFFFFFFFFFFFFFF; // int max

      if (i < divisionChanges.length - 1)
        nextDivisionStart = divisionChanges[i + 1].offset;

      if (timePtr >= nextDivisionStart) {
        timePtr = nextDivisionStart;
        i++;
        continue;
      }

      while (timePtr < nextDivisionStart && timePtr < timeView.end) {
        var x = timeToPixels(
            timeView: timeView, viewPixelWidth: size.width, time: timePtr.toDouble());

        canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), color);

        timePtr += thisDivision.divisionRenderSize;
      }

      i++;
    }

    // Draws everything since canvas.saveLayer() with the color provided in
    // canvas.saveLayer(). This means that overlapping areas won't be darker.
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PianoRollBackgroundPainter oldDelegate) {
    return oldDelegate.keyHeight != this.keyHeight ||
        oldDelegate.keyValueAtTop != this.keyValueAtTop;
  }
}
