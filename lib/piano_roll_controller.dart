import 'package:flutter/widgets.dart';
import 'package:flutter_piano_roll/piano_roll.dart';

class PianoRollController extends StatelessWidget {
  const PianoRollController({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<NotePointerNotification>(
        onNotification: (notification) {
          print(
              "key: ${notification.noteID} - pressed: ${notification.pressed}, rmb: ${notification.isRightClick}");

          return true;
        },
        child: child);
  }
}