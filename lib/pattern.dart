import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'globals.dart';

class TimeSignature {
  TimeSignature(this.numerator, this.denominator);

  final int numerator;
  final int denominator;
}

class TimeSignatureChange {
  TimeSignatureChange({required this.offset, required this.timeSignature});

  final int offset;
  final TimeSignature timeSignature;
}

class Note {
  Note({
    required this.id,
    required this.offset,
    required this.length,
    required this.key,
    required this.velocity,
  });

  final int id;

  final int offset;
  final int length;

  // u8
  final int key;
  final int velocity;
  // final int midiChannel;
}

class Pattern with ChangeNotifier, DiagnosticableTreeMixin {
  TimeSignature _baseTimeSignature = TimeSignature(4, 4);
  TimeSignature get baseTimeSignature => _baseTimeSignature;
  void setBaseTimeSignature(TimeSignature timeSignature) {
    _baseTimeSignature = timeSignature;
    notifyListeners();
  }

  List<TimeSignatureChange> timeSignatureChanges = [];
  List<Note> notes = [
    Note(id: getID(), key: 64, offset: 0, length: 96, velocity: 200),
    Note(id: getID(), key: 66, offset: 96, length: 96, velocity: 200),
    Note(id: getID(), key: 68, offset: 96 * 2, length: 96, velocity: 200),
    Note(id: getID(), key: 71, offset: 96 * 3, length: 96, velocity: 200),

    Note(id: getID(), key: 64 + 1, offset: 0, length: 96 * 3 ~/ 4, velocity: 200),
    Note(id: getID(), key: 66 + 2, offset: 96, length: 96 * 3 ~/ 4, velocity: 200),
    Note(id: getID(), key: 68 + 1, offset: 96 * 2, length: 96 * 3 ~/ 4, velocity: 200),
    Note(id: getID(), key: 71 + 2, offset: 96 * 3, length: 96 * 3 ~/ 4, velocity: 200),

    Note(id: getID(), key: 64 + 3, offset: 0, length: 96 ~/ 2, velocity: 200),
    Note(id: getID(), key: 66 + 4, offset: 96, length: 96 ~/ 2, velocity: 200),
    Note(id: getID(), key: 68 + 3, offset: 96 * 2, length: 96 ~/ 2, velocity: 200),
    Note(id: getID(), key: 71 + 4, offset: 96 * 3, length: 96 ~/ 2, velocity: 200),
  ];

  void mutateNotes(void Function(List<Note> notes) mutator) {
    mutator(notes);
    notifyListeners();
  }

  final int ticksPerBeat = 96;
}
