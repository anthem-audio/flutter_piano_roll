import 'package:flutter_piano_roll/pattern.dart';

enum KeyType { BLACK, WHITE }
enum NotchType { ABOVE, BELOW, BOTH }

KeyType getKeyType(int key) {
  switch (key % 12) {
    case 1:
    case 4:
    case 6:
    case 9:
    case 11:
      return KeyType.BLACK;
    default:
      return KeyType.WHITE;
  }
}

NotchType getNotchType(int key) {
  final keyTypeBelow = getKeyType(key - 1);
  final keyTypeAbove = getKeyType(key + 1);

  if (keyTypeAbove == KeyType.BLACK && keyTypeBelow == KeyType.WHITE) {
    return NotchType.ABOVE;
  } else if (keyTypeAbove == KeyType.WHITE && keyTypeBelow == KeyType.BLACK) {
    return NotchType.BELOW;
  }

  return NotchType.BOTH;
}

double keyValueToPixels({
  required double keyValue,
  required double keyValueAtTop,
  required double keyHeight,
}) {
  final keyOffsetFromTop = keyValueAtTop - keyValue;
  return keyOffsetFromTop * keyHeight;
}

double pixelsToKeyValue({
  required double pixelOffsetFromTop,
  required double keyValueAtTop,
  required double keyHeight,
}) {
  final keyOffsetFromTop = pixelOffsetFromTop / keyHeight;
  return keyValueAtTop - keyOffsetFromTop;
}

class TimeView {
  TimeView({
    required this.start,
    required this.end,
  });

  double start;
  double end;
}

class Division {
  Division({
    required this.multiplier,
    required this.divisor,
  });

  int multiplier;
  int divisor;

  Time getSizeInTicks(Time ticksPerQuarter, TimeSignature timeSignature) {
    return ((ticksPerQuarter * 4) ~/ timeSignature.denominator) *
        multiplier ~/
        divisor;
  }
}

abstract class Snap {}

class BarSnap extends Snap {}

class DivisionSnap extends Snap {
  DivisionSnap({required this.division});
  Division division;
}

typedef Time = int;

// This is ported from Rust. I don't know what I was doing, but the naming here
// is confusing. Why doesn't this contain a Division? Should it? I don't want
// to think this through now, so I'm leaving a note.

class DivisionChange {
  DivisionChange({
    required this.offset,
    required this.divisionRenderSize,
    required this.divisionSnapSize,
    required this.distanceBetween,
    required this.startLabel,
  });

  Time offset;
  Time divisionRenderSize;
  Time divisionSnapSize;
  int distanceBetween;
  int startLabel;
}

Time getBarLength(Time ticksPerQuarter, TimeSignature timeSignature) {
  return (ticksPerQuarter * 4 * timeSignature.numerator) ~/
      timeSignature.denominator;
}

class GetBestDivisionResult {
  GetBestDivisionResult({
    required this.renderSize,
    required this.snapSize,
    required this.skip,
  });

  Time renderSize;
  Time snapSize;
  int skip;
}

// Adapted from https://github.com/wackywendell/primes
int firstFactor(int x) {
  if (x % 2 == 0) {
    return 2;
  }

  // Odd numbers starting at 3
  for (int i = 3; i * i <= x; i += 2) {
    if (x % i == 0) {
      return i;
    }
  }

  // No factor found. It must be prime.
  return x;
}

// Adapted from https://github.com/wackywendell/primes
List<int> factors(int x) {
  if (x <= 1) {
    return [];
  }

  List<int> result = [];
  var curn = x;
  while (true) {
    // var m =
  }
}

GetBestDivisionResult getBestDivision({
  required TimeSignature timeSignature,
  required Snap snap,
  required double ticksPerPixel,
  required double minPixelsPerDivision,
  required int ticksPerQuarter,
}) {
  var barLength = getBarLength(ticksPerQuarter, timeSignature);
  var divisionSizeLowerBound = ticksPerPixel * minPixelsPerDivision as int;

  // bestDivision starts at some small value and works up to the smallest valid
  // value
  int bestDivision;
  int snapSize;
  int skip = 1;

  if (snap is BarSnap) {
    bestDivision = barLength;
    snapSize = barLength;
  } else if (snap is DivisionSnap) {
    if (divisionSizeLowerBound >= barLength) {
      snapSize = barLength;
    } else {
      var division = snap.division;
      snapSize = division.getSizeInTicks(ticksPerQuarter, timeSignature);
    }
    bestDivision = snapSize;
  } else {
    // This isn't TypeScript, so (I think) we can't verify completeness here.
    // If Snap gets more subclasses then this could give a runtime error.
    throw new ArgumentError("Unhandled Snap type");
  }

  var numDivisionsInBar = barLength ~/ snapSize;

  if (bestDivision < barLength) {
    var multipliers = factors(numDivisionsInBar);

    for (var multiplier in multipliers) {
      if (bestDivision >= divisionSizeLowerBound) {
        return GetBestDivisionResult(
          renderSize: bestDivision,
          snapSize: snapSize,
          skip: skip,
        );
      }

      bestDivision *= multiplier;
    }
  }

  // If we got here, then bestDivision will be equal to barLength

  while (bestDivision < divisionSizeLowerBound) {
    bestDivision *= 2;
    skip *= 2;
  }

  return GetBestDivisionResult(
    renderSize: bestDivision,
    snapSize: snapSize,
    skip: skip,
  );
}

List<DivisionChange> getDivisionChanges({
  required double viewWidthInPixels,
  required double minPixelsPerSection,
  required Snap snap,
  required TimeSignature defaultTimeSignature,
  required List<TimeSignatureChange> timeSignatureChanges,
  required int ticksPerQuarter,
  required TimeView timeView,
}) {
  if (viewWidthInPixels < 1) {
    return [];
  }

  List<DivisionChange> result = [];

  var startLabelPtr = 1;
  var divisionStartPtr = 0;
  var divisionBarLength = 1;

  var processTimeSignatureChange = (TimeSignatureChange change) {
    var lastDivisionSize = change.offset - divisionStartPtr;
    startLabelPtr += lastDivisionSize ~/ divisionBarLength;
    if (lastDivisionSize % divisionBarLength > 0) {
      startLabelPtr++;
    }

    divisionStartPtr = change.offset;
    divisionBarLength = getBarLength(ticksPerQuarter, change.timeSignature);

    var bestDivision = getBestDivision(
      minPixelsPerDivision: minPixelsPerSection,
      snap: snap,
      ticksPerPixel: (timeView.end - timeView.start) / viewWidthInPixels,
      ticksPerQuarter: ticksPerQuarter,
      timeSignature: change.timeSignature,
    );

    var nthDivision = bestDivision.skip;

    return DivisionChange(
      offset: change.offset,
      divisionRenderSize: bestDivision.renderSize,
      divisionSnapSize: bestDivision.snapSize,
      distanceBetween: nthDivision,
      startLabel: startLabelPtr,
    );
  };

  if (timeSignatureChanges.length == 0 || timeSignatureChanges[0].offset > 0) {
    result.add(processTimeSignatureChange(
      TimeSignatureChange(offset: 0, timeSignature: defaultTimeSignature),
    ));
  }

  for (var change in timeSignatureChanges) {
    result.add(processTimeSignatureChange(change));
  }

  return result;
}
