import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

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

class Pattern with ChangeNotifier, DiagnosticableTreeMixin {
  TimeSignature _baseTimeSignature = TimeSignature(4, 4);
  TimeSignature get baseTimeSignature => _baseTimeSignature;
  void setBaseTimeSignature(TimeSignature timeSignature) {
    this._baseTimeSignature = timeSignature;
    notifyListeners();
  }

  List<TimeSignatureChange> timeSignatureChanges = [];

  final int ticksPerBeat = 96;
}
