import 'package:flutter/widgets.dart';

// Notifications that describe pointer events on notes. How they are handled
// will depend on the current state of the piano roll controller.
class NotePointerNotification extends Notification {
  NotePointerNotification({
    required this.noteID,
    required this.pressed,
    required this.isRightClick,
  });

  final int noteID;
  final bool pressed;
  final bool isRightClick;
}

abstract class PianoRollNotification extends Notification {}

abstract class PianoRollPointerNotification extends PianoRollNotification {
  PianoRollPointerNotification({
    required this.note,
    required this.time,
    required this.event,
  });

  // MIDI note at cursor. Fraction indicates position in note.
  final double note;

  // Time at cursor. Fraction indicates position within tick.
  final double time;

  // Determines if this is caused by a right click.
  final PointerEvent event;
}

class PianoRollPointerDownNotification extends PianoRollPointerNotification {
  PianoRollPointerDownNotification({
    required double note,
    required double time,
    required PointerDownEvent event,
  }) : super(note: note, time: time, event: event);
}

class PianoRollPointerMoveNotification extends PianoRollPointerNotification {
  PianoRollPointerMoveNotification({
    required double note,
    required double time,
    required PointerMoveEvent event,
  }) : super(note: note, time: time, event: event);
}

class PianoRollPointerUpNotification extends PianoRollPointerNotification {
  PianoRollPointerUpNotification({
    required double note,
    required double time,
    required PointerUpEvent event,
  }) : super(note: note, time: time, event: event);
}
