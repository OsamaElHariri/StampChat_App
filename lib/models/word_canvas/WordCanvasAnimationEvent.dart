import 'package:StampChat/models/Message.dart';
import 'package:StampChat/models/word_canvas/WordCanvasAnimationState.dart';
import 'package:flutter/material.dart';

class WordCanvasAnimationEvent {
  Offset position;
  WordCanvasAnimationState state;
  Message message;

  WordCanvasAnimationEvent({this.position, this.state, this.message});
}
