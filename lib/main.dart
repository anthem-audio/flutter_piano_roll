import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_piano_roll/piano_roll.dart';

void main() {
  runApp(
    WidgetsApp(
        color: Color.fromARGB(255, 7, 210, 212),
        title: "Piano Roll",
        builder: (env, widget) => AppWrapper()),
  );
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Image.asset("assets/images/background-small.jpg",
              fit: BoxFit.cover),
        ),
        Container(
          color: Color.fromARGB(77, 0, 0, 0),
        ),
        PianoRoll(),
      ],
    );
  }
}
