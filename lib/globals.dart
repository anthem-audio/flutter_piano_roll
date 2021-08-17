class KeyboardModifiers {
  bool ctrl = false;
  bool alt = false;
  bool shift = false;
}

KeyboardModifiers keyboardModifiers = KeyboardModifiers();

var ticksPerQuarter = 96;

var _idGen = 0;
int getID() {
  return _idGen++;
}
