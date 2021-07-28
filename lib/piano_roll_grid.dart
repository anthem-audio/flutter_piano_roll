import 'package:flutter/widgets.dart';

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
    return Container(
      child: ClipRect(
        // child: Container(color: Color(0xFF00FF00)),
        child: CustomPaint(
          painter: PianoRollBackgroundPainter(
            keyHeight: keyHeight,
            keyValueAtTop: keyValueAtTop,
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
  });

  final double keyHeight;
  final double keyValueAtTop;

  @override
  void paint(Canvas canvas, Size size) {
    var color = Paint();
    color.color = Color(0xFFFFFFFF);
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Color(0xFF000000).withOpacity(0.2),
    );

    var linePointer = keyHeight - ((keyValueAtTop * keyHeight) % keyHeight);

    while (linePointer < size.height) {
      canvas.drawRect(Rect.fromLTWH(0, linePointer, size.width, 1), color);
      linePointer += keyHeight;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PianoRollBackgroundPainter oldDelegate) {
    return oldDelegate.keyHeight != this.keyHeight ||
        oldDelegate.keyValueAtTop != this.keyValueAtTop;
  }
}
