class KeyboardModifiers {
  bool control = false;
  bool alt = false;
  bool shift = false;
}

KeyboardModifiers keyboardModifiers = KeyboardModifiers();

var _idGen = 0;
int getID() {
  return _idGen++;
}
