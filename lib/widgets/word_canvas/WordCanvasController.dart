import 'dart:async';

import 'package:StampChat/models/Stamp.dart';
import 'package:StampChat/models/word_canvas/WordCanvasAnimationEvent.dart';

class WordCanvasController {
  StreamController<WordCanvasAnimationEvent> _animationStateController =
      StreamController<WordCanvasAnimationEvent>.broadcast();
  Stream<WordCanvasAnimationEvent> get onAnimationStateChange =>
      _animationStateController.stream;

  StreamController<List<Stamp>> _wordStreamController =
      StreamController<List<Stamp>>.broadcast();
  Stream<List<Stamp>> get onStamp => _wordStreamController.stream;

  void addStamps(List<Stamp> stamps) {
    _wordStreamController.add(stamps);
  }

  void addAnimationEvent(WordCanvasAnimationEvent event) {
    _animationStateController.add(event);
  }
}
