import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

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
    this._baseTimeSignature = timeSignature;
    notifyListeners();
  }

  List<TimeSignatureChange> timeSignatureChanges = [];
  List<Note> notes = [
    Note(id: getID(), key: 64, offset: 0, length: 96, velocity: 200),
    Note(id: getID(), key: 66, offset: 96, length: 96, velocity: 200),
    Note(id: getID(), key: 68, offset: 96 * 2, length: 96, velocity: 200),
    Note(id: getID(), key: 71, offset: 96 * 3, length: 96, velocity: 200),
  ];

  final int ticksPerBeat = 96;
}
