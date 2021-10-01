import 'package:flutter/widgets.dart';
import 'package:flutter_piano_roll/globals.dart';
import 'package:flutter_piano_roll/piano_roll_notifications.dart';
import 'package:flutter_piano_roll/pattern.dart';
import 'package:provider/provider.dart';

import 'helpers.dart';

class PianoRollController extends StatelessWidget {
  const PianoRollController({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<PianoRollNotification>(
        onNotification: (notification) {
          final pattern = Provider.of<Pattern>(context, listen: false);
          final timeView = Provider.of<TimeView>(context, listen: false);

          /*
            This feels excessive, as it recalculates snap for each
            notification. I'm not sure whether this is actually slower than
            memoizing in the average case, so it's probably best to profile
            before going down that route.
          */

          final divisionChanges = getDivisionChanges(
            viewWidthInPixels: notification.pianoRollSize.width,
            // TODO: this constant was copied from the minor division changes
            // getter in piano_roll_grid.dart
            minPixelsPerSection: 8,
            snap: DivisionSnap(division: Division(multiplier: 1, divisor: 4)),
            defaultTimeSignature: pattern.baseTimeSignature,
            timeSignatureChanges: pattern.timeSignatureChanges,
            ticksPerQuarter: pattern.ticksPerBeat,
            timeViewStart: timeView.start,
            timeViewEnd: timeView.end,
          );

          if (notification is PianoRollPointerDownNotification) {
            print(
                "pointer down: ${notification.note}, time: ${notification.time}");

            final notificationTime = notification.time.floor();
            int targetTime = -1;

            // A binary search might be better here, but it would only matter
            // if there were a *lot* of time signature changes in the pattern
            for (var i = 0; i < divisionChanges.length; i++) {
              if (notificationTime < 0 ||
                  (i < divisionChanges.length - 1 &&
                      divisionChanges[i + 1].offset <= notificationTime)) {
                continue;
              }

              final divisionChange = divisionChanges[i];
              final snapSize = divisionChange.divisionSnapSize;
              targetTime = (notificationTime ~/ snapSize) * snapSize;
              print(i);
              break;
            }

            pattern.mutateNotes((notes) {
              notes.add(Note(
                  id: getID(),
                  key: notification.note.floor(),
                  length: 96,
                  offset: targetTime,
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
