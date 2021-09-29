import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_piano_roll/helpers.dart';
import 'package:flutter_piano_roll/piano_roll_notifications.dart';
import 'package:flutter_piano_roll/pattern.dart';
import 'package:flutter_piano_roll/piano_roll_grid.dart';
import 'package:flutter_piano_roll/timeline.dart';
import 'package:provider/provider.dart';

import './piano_control.dart';

class PianoRoll extends StatefulWidget {
  const PianoRoll({Key? key}) : super(key: key);

  @override
  _PianoRollState createState() => _PianoRollState();
}

class _PianoRollState extends State<PianoRoll> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Column(
        children: [
          _PianoRollHeader(),
          Expanded(
            child: _PianoRollContent(),
          ),
        ],
      ),
    );
  }
}

class _PianoRollHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.12),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
      ),
      height: 42,
    );
  }
}

class _PianoRollContent extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pattern = context.watch<Pattern>();
    final timeView = context.watch<TimeView>();

    final footerHeight = useState<double>(61);
    final pianoControlWidth = useState<double>(103);
    final keyValueAtTop = useState<double>(64);
    final keyHeight = useState<double>(20);

    final timelineHeight =
        pattern.timeSignatureChanges.isNotEmpty ? 42.0 : 21.0;

    final pianoRollContentListenerKey = GlobalKey();

    handlePointerDown(PointerDownEvent e) {
      final context = pianoRollContentListenerKey.currentContext;
      if (context == null) return;

      final contentRenderBox = context.findRenderObject() as RenderBox;
      final pointerPos = contentRenderBox.globalToLocal(e.position);

      PianoRollPointerDownNotification(
              note: pixelsToKeyValue(
                  keyHeight: keyHeight.value,
                  keyValueAtTop: keyValueAtTop.value,
                  pixelOffsetFromTop: pointerPos.dy),
              time: pixelsToTime(
                  timeViewStart: timeView.start,
                  timeViewEnd: timeView.end,
                  viewPixelWidth: context.size?.width ?? 1,
                  pixelOffsetFromLeft: pointerPos.dx),
              event: e)
          .dispatch(context);
    }

    handlePointerMove(PointerMoveEvent e) {
      final context = pianoRollContentListenerKey.currentContext;
      if (context == null) return;

      final contentRenderBox = context.findRenderObject() as RenderBox;
      final pointerPos = contentRenderBox.globalToLocal(e.position);

      PianoRollPointerMoveNotification(
        note: pixelsToKeyValue(
            keyHeight: keyHeight.value,
            keyValueAtTop: keyValueAtTop.value,
            pixelOffsetFromTop: pointerPos.dy),
        time: pixelsToTime(
            timeViewStart: timeView.start,
            timeViewEnd: timeView.end,
            viewPixelWidth: context.size?.width ?? 1,
            pixelOffsetFromLeft: pointerPos.dx),
        event: e,
      ).dispatch(context);
    }

    handlePointerUp(PointerUpEvent e) {
      final context = pianoRollContentListenerKey.currentContext;
      if (context == null) return;

      final contentRenderBox = context.findRenderObject() as RenderBox;
      final pointerPos = contentRenderBox.globalToLocal(e.position);

      PianoRollPointerUpNotification(
        note: pixelsToKeyValue(
            keyHeight: keyHeight.value,
            keyValueAtTop: keyValueAtTop.value,
            pixelOffsetFromTop: pointerPos.dy),
        time: pixelsToTime(
            timeViewStart: timeView.start,
            timeViewEnd: timeView.end,
            viewPixelWidth: context.size?.width ?? 1,
            pixelOffsetFromLeft: pointerPos.dx),
        event: e,
      ).dispatch(context);
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Piano control
              SizedBox(
                width: pianoControlWidth.value,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF).withOpacity(0.12),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(1),
                          bottomRight: Radius.circular(1),
                        ),
                      ),
                      height: timelineHeight + 1,
                    ),
                    const SizedBox(height: 1),
                    Expanded(
                      child: PianoControl(
                        keyValueAtTop: keyValueAtTop.value,
                        keyHeight: keyHeight.value,
                        setKeyValueAtTop: (value) {
                          keyValueAtTop.value = value;
                        },
                        setKeyHeight: (value) {
                          keyHeight.value = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 1),
                  ],
                ),
              ),
              // Timeline and main piano roll render area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(1, 1, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: timelineHeight,
                        child: Timeline(
                          pattern: pattern,
                        ),
                      ),
                      Expanded(
                        child: Listener(
                          key: pianoRollContentListenerKey,
                          onPointerDown: handlePointerDown,
                          onPointerMove: handlePointerMove,
                          onPointerUp: handlePointerUp,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              PianoRollGrid(
                                keyHeight: keyHeight.value,
                                keyValueAtTop: keyValueAtTop.value,
                              ),
                              ClipRect(
                                child: CustomMultiChildLayout(
                                  children: pattern.notes
                                      .map(
                                        (note) => LayoutId(
                                          id: note.id,
                                          child: NoteWidget(noteID: note.id),
                                        ),
                                      )
                                      .toList(),
                                  delegate: NoteLayoutDelegate(
                                    notes: pattern.notes,
                                    keyHeight: keyHeight.value,
                                    keyValueAtTop: keyValueAtTop.value,
                                    timeViewStart: timeView.start,
                                    timeViewEnd: timeView.end,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: const Color(0xFFFFFFFF).withOpacity(0.12),
          height: footerHeight.value,
        ),
      ],
    );
  }
}

class NoteLayoutDelegate extends MultiChildLayoutDelegate {
  NoteLayoutDelegate({
    required this.notes,
    required this.keyHeight,
    required this.keyValueAtTop,
    required this.timeViewStart,
    required this.timeViewEnd,
  });

  final List<Note> notes;
  final double timeViewStart;
  final double timeViewEnd;
  final double keyValueAtTop;
  final double keyHeight;

  @override
  void performLayout(Size size) {
    for (var note in notes) {
      // layoutChild(
      //   1,
      // BoxConstraints(
      //   maxWidth: size.width,
      //   maxHeight: size.height,
      // ),
      // );
      // positionChild(1, Offset(5, 21));

      final y = keyValueToPixels(
              keyValue: note.key.toDouble(),
              keyValueAtTop: keyValueAtTop,
              keyHeight: keyHeight) +
          // this is why I want Dart support for Prettier
          1;
      final height = keyHeight.toDouble() - 1;
      final startX = timeToPixels(
              timeViewStart: timeViewStart,
              timeViewEnd: timeViewEnd,
              viewPixelWidth: size.width,
              time: note.offset.toDouble()) +
          1;
      final width = timeToPixels(
              timeViewStart: timeViewStart,
              timeViewEnd: timeViewEnd,
              viewPixelWidth: size.width,
              time: timeViewStart + note.length.toDouble()) -
          1;

      layoutChild(
        note.id,
        BoxConstraints(maxHeight: height, maxWidth: width),
      );
      positionChild(note.id, Offset(startX, y));
    }
  }

  @override
  bool shouldRelayout(covariant NoteLayoutDelegate oldDelegate) {
    if (oldDelegate.timeViewStart != timeViewStart ||
        oldDelegate.timeViewEnd != timeViewEnd ||
        oldDelegate.notes.length != notes.length ||
        oldDelegate.keyHeight != keyHeight ||
        oldDelegate.keyValueAtTop != keyValueAtTop) return true;
    for (var i = 0; i < notes.length; i++) {
      var oldNote = oldDelegate.notes[i];
      var newNote = notes[i];

      // No re-layout on velocity. I think this is okay?
      if (oldNote.key != newNote.key ||
          oldNote.length != newNote.length ||
          oldNote.offset != newNote.offset) {
        return true;
      }
    }
    return false;
  }
}

class NoteWidget extends HookWidget {
  const NoteWidget({Key? key, required this.noteID}) : super(key: key);

  final int noteID;

  @override
  Widget build(BuildContext context) {
    final isHovered = useState(false);

    return Listener(
      // TODO: Send off notification on focus loss (?) or people will be very confused maybe
      onPointerDown: (e) {
        // NotePointerNotification(
        //   isRightClick: e.buttons == kSecondaryMouseButton,
        //   pressed: true,
        //   noteID: 1,
        // ).dispatch(context);
        // PianoRollNotification().dispatch(context);
      },
      // onPointerUp: (e) {
      //   NotePointerNotification(
      //     isRightClick: e.buttons == kSecondaryMouseButton,
      //     pressed: false,
      //     noteID: 1,
      //   ).dispatch(context);
      // },
      child: MouseRegion(
        onEnter: (e) {
          isHovered.value = true;
        },
        onExit: (e) {
          isHovered.value = false;
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF07D2D4)
                .withOpacity(isHovered.value ? 0.5 : 0.33),
            borderRadius: const BorderRadius.all(Radius.circular(1)),
          ),
        ),
      ),
    );
  }
}
