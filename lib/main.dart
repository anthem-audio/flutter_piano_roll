import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'globals.dart';
import 'helpers.dart';
import 'pattern.dart';
import 'piano_roll.dart';
import 'piano_roll_controller.dart';

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
        var type = e.runtimeType.toString();

        var keyDown = type == 'RawKeyDownEvent';
        var keyUp = type == 'RawKeyUpEvent';

        print(e.logicalKey.keyLabel);

        var ctrl = e.logicalKey.keyLabel == "Control Left" ||
            e.logicalKey.keyLabel == "Control Right";
        var alt = e.logicalKey.keyLabel == "Alt Left" ||
            e.logicalKey.keyLabel == "Alt Right";
        var shift = e.logicalKey.keyLabel == "Shift Left" ||
            e.logicalKey.keyLabel == "Shift Right";

        if (ctrl && keyDown) keyboardModifiers.ctrl = true;
        if (ctrl && keyUp) keyboardModifiers.ctrl = false;
        if (alt && keyDown) keyboardModifiers.alt = true;
        if (alt && keyUp) keyboardModifiers.alt = false;
        if (shift && keyDown) keyboardModifiers.shift = true;
        if (shift && keyUp) keyboardModifiers.shift = false;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Image.asset(
              "assets/images/background-small.jpg",
              fit: BoxFit.cover,
              color: const Color.fromARGB(77, 0, 0, 0),
              colorBlendMode: BlendMode.luminosity,
            ),
          ),
          const PianoRollController(child: PianoRoll()),
        ],
      ),
    );
  }
}
