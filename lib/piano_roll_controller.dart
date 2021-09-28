import 'package:flutter/widgets.dart';
import 'package:flutter_piano_roll/paino_roll_notifications.dart';

class PianoRollController extends StatelessWidget {
  const PianoRollController({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<PianoRollNotification>(
        onNotification: (notification) {
          
          return true;
        },
        child: child);
  }
}
