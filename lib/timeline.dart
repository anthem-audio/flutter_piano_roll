import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_piano_roll/pattern.dart';
import 'package:provider/provider.dart';

class Timeline extends HookWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        color: Color(0xFFFFFFFF).withOpacity(0.12),
        child: Center(child: Text('${context.watch<Pattern>().ticksPerBeat}')),
      ),
    );
  }
}
