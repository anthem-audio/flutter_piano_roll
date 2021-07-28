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
