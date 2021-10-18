import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_piano_roll/helpers.dart';
import 'package:flutter_piano_roll/piano_roll.dart';
import 'package:flutter_piano_roll/piano_roll_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_piano_roll/pattern.dart';

import 'globals.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Pattern()
            ..timeSignatureChanges = [
              TimeSignatureChange(
                offset: 96 * 4,
                timeSignature: TimeSignature(5, 8),
              ),
            ],
        ),
        ChangeNotifierProvider(create: (_) => TimeView(0, 3072)),
      ],
      child: WidgetsApp(
        color: const Color.fromARGB(255, 7, 210, 212),
        title: "Piano Roll",
        builder: (env, widget) => const AppWrapper(),
      ),
    ),
  );
}

class AppWrapper extends HookWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (e) {
        keyboardModifiers.control = e.isControlPressed;
        keyboardModifiers.alt = e.isAltPressed;
        keyboardModifiers.shift = e.isShiftPressed;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Image.asset("assets/images/background-small.jpg",
                fit: BoxFit.cover),
          ),
          Container(
            color: const Color.fromARGB(77, 0, 0, 0),
          ),
          const PianoRollController(child: PianoRoll()),
        ],
      ),
    );
  }
}
