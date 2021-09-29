import 'package:flutter/widgets.dart';
import 'package:flutter_piano_roll/globals.dart';
import 'package:flutter_piano_roll/piano_roll_notifications.dart';
import 'package:flutter_piano_roll/pattern.dart';
import 'package:provider/provider.dart';

class PianoRollController extends StatelessWidget {
  const PianoRollController({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<PianoRollNotification>(
        onNotification: (notification) {
          if (notification is PianoRollPointerDownNotification) {
            print(
                "pointer down: ${notification.note}, time: ${notification.time}");
            Provider.of<Pattern>(context, listen: false).mutateNotes((notes) {
              notes.add(Note(
                  id: getID(),
                  // TODO: This should absolutely be floor(). This means there's a bug elsewhere.
                  key: notification.note.ceil(),
                  length: 96,
                  offset: notification.time.floor(),
                  velocity: 128));
            });
            return true;
          } else if (notification is PianoRollPointerMoveNotification) {
            print(
                "pointer move: ${notification.note}, time: ${notification.time}");
            return true;
          } else if (notification is PianoRollPointerUpNotification) {
            print(
                "pointer up: ${notification.note}, time: ${notification.time}");
            return true;
          }
          return false;
        },
        child: child);
  }
}
