import 'dart:async';
import 'dart:collection';

import 'package:StampChat/models/Message.dart';
import 'package:StampChat/models/Stamp.dart';
import 'package:StampChat/models/word_canvas/WordCanvasAnimationEvent.dart';
import 'package:StampChat/models/word_canvas/WordCanvasAnimationState.dart';
import 'package:StampChat/widgets/chat/ChannelEventRandomElements.dart';
import 'package:StampChat/widgets/word_canvas/WordCanvasController.dart';
import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';

class MessageCanvas extends StatefulWidget {
  final ImageMap images;
  final WordCanvasController controller;
  final Function(Message, num, Offset) onTap;
  final Size size;
  final Message message;

  MessageCanvas({
    Key key,
    @required this.controller,
    @required this.message,
    @required this.size,
    @required this.onTap,
    @required this.images,
  }) : super(key: key);

  @override
  _MessageCanvasState createState() => _MessageCanvasState();
}

class _MessageCanvasState extends State<MessageCanvas> {
  NodeWithSize _rootNode;
  Sprite smokeEffect;
  Sprite secondarySmokeEffect;

  StreamSubscription _stampListener;
  StreamSubscription _animationStateListener;

  DateTime initTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _rootNode =
        _MessageCanvasNode(widget.size, widget.controller, widget.message);
    _stampListener = widget.controller.onStamp.listen(addStamps);
    _animationStateListener =
        widget.controller.onAnimationStateChange.listen(_onAnimationEvent);

    WidgetsFlutterBinding.ensureInitialized().scheduleFrameCallback((_) {
      addStamps(widget.message.stamps);
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    _stampListener?.cancel();
    _animationStateListener?.cancel();
  }

  void addStamps(List<Stamp> stamps) {
    if (stamps == null || stamps.isEmpty) return;
    stamps.forEach((stamp) {
      _addStamp(stamp);
    });
  }

  void _addStamp(Stamp stamp) {
    if (stamp.messageId != widget.message.id) return;

    var position =
        Offset(widget.size.width * stamp.xPos, widget.size.height * stamp.yPos);
    var rotation = ChannelEventRandomElements.getStampRotation(stamp.id);
    var text = _getWordNode(stamp);
    var effect = _getWordTexturetNode(stamp);
    var wordBorder = _getWordBorder(stamp);

    var stampNode = Node()
      ..rotation = rotation
      ..position = position.translate(0, -16)
      ..scale = 0.5 + stamp.strength * 0.5;
    stampNode.addChild(wordBorder);
    stampNode.addChild(text);
    stampNode.addChild(effect);
    _rootNode.addChild(stampNode);
  }

  Node _getWordNode(Stamp stamp) {
    return Node()
      ..addChild(Label(
        stamp.word,
        textAlign: TextAlign.center,
        textStyle: TextStyle(
            fontFamily: 'Orbitron',
            color: ChannelEventRandomElements.getStampColor(stamp.memberId),
            fontSize: 26.0,
            fontWeight: FontWeight.w600),
      ));
  }

  Node _getWordTexturetNode(Stamp stamp) {
    return Sprite.fromImage(widget.images.getImage("assets/grunge.png"))
      ..pivot = Offset(0.5, 0.5)
      ..position = Offset(0, 16)
      ..scaleX = 1.6
      ..colorOverlay = Theme.of(context).accentColor
      ..opacity = 0.6;
  }

  Node _getWordBorder(Stamp stamp) {
    String imagePath =
        ChannelEventRandomElements.getStampBorderAsset(stamp.memberId);
    return Sprite.fromImage(widget.images.getImage(imagePath))
      ..pivot = Offset(0.5, 0.5)
      ..position = Offset(0, 16)
      ..colorOverlay = ChannelEventRandomElements.getStampColor(stamp.memberId)
      ..opacity = 0.85;
  }

  void _onAnimationEvent(WordCanvasAnimationEvent event) {
    if (event.message.id != widget.message.id) return;
    if (event.state == WordCanvasAnimationState.stampInit) {
      initTime = DateTime.now();
      _initSmokeEffect(event.position);
    } else if (event.state == WordCanvasAnimationState.stampEnd) {
      var strength = DateTime.now().difference(initTime).inMilliseconds / 1000;
      widget.onTap(
          widget.message,
          strength,
          Offset(event.position.dx / widget.size.width,
              event.position.dy / widget.size.height));
      _endSmokeEffect();
    }
  }

  void _initSmokeEffect(Offset position) {
    if (smokeEffect != null && smokeEffect.parent != null)
      smokeEffect.removeFromParent();
    if (secondarySmokeEffect != null && secondarySmokeEffect.parent != null)
      secondarySmokeEffect.removeFromParent();

    smokeEffect =
        Sprite.fromImage(widget.images.getImage("assets/smoke_ring.png"))
          ..position = position
          ..colorOverlay = Theme.of(context).primaryColor;
    smokeEffect.motions.run(
        MotionGroup(_getSmokeEffectEnterMotions(smokeEffect, Curves.easeIn)));
    _rootNode.addChild(smokeEffect);

    secondarySmokeEffect =
        Sprite.fromImage(widget.images.getImage("assets/smoke_ring.png"))
          ..position = position
          ..colorOverlay = Theme.of(context).primaryColor;
    secondarySmokeEffect.motions.run(MotionGroup(
        _getSmokeEffectEnterMotions(secondarySmokeEffect, Curves.easeInCubic)));
    _rootNode.addChild(secondarySmokeEffect);
  }

  List<Motion> _getSmokeEffectEnterMotions(Sprite sprite, Curve curve) {
    Motion rotate = MotionTween<double>((r) => sprite.rotation = r, 0, 500, 1);
    MotionTween compress =
        MotionTween<double>((s) => sprite.scale = s, 1.5, 0.9, 1, curve);
    MotionTween fadeIn =
        MotionTween<double>((o) => sprite.opacity = o, 0, 0.08, 0.05);
    return [rotate, compress, fadeIn];
  }

  void _endSmokeEffect() {
    if (smokeEffect == null) return;
    smokeEffect.motions.stopAll();
    secondarySmokeEffect.motions.stopAll();
    smokeEffect.motions.run(
        MotionGroup(_getSmokeEffectExitMotions(smokeEffect, Curves.easeOut)));
    secondarySmokeEffect.motions.run(MotionGroup(
        _getSmokeEffectExitMotions(secondarySmokeEffect, Curves.easeOutCubic)));
  }

  List<Motion> _getSmokeEffectExitMotions(Sprite sprite, Curve curve) {
    MotionTween expand = MotionTween<double>(
        (s) => sprite.scale = s, sprite.scale, 5, 0.4, curve);
    MotionTween fadeOut =
        MotionTween<double>((o) => sprite.opacity = o, sprite.opacity, 0, 0.4);
    return [expand, fadeOut];
  }

  @override
  Widget build(BuildContext context) {
    return SpriteWidget(_rootNode);
  }
}

class _MessageCanvasNode extends NodeWithSize {
  WordCanvasController _controller;
  Message _message;

  _MessageCanvasNode(Size size, this._controller, this._message) : super(size) {
    userInteractionEnabled = true;
  }

  HashSet<int> pressedPointers = HashSet.identity();

  @override
  handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerDownEvent)
      _handlePointerDown(event);
    else if (event.type == PointerUpEvent) _handlePointerUp(event);

    return true;
  }

  void _handlePointerDown(SpriteBoxEvent event) {
    pressedPointers.add(event.pointer);
    Future.delayed(Duration(seconds: 1))
        .then((value) => _handlePointerUp(event));
    _controller.addAnimationEvent(WordCanvasAnimationEvent(
        message: _message,
        position: event.boxPosition,
        state: WordCanvasAnimationState.stampInit));
  }

  void _handlePointerUp(SpriteBoxEvent event) {
    if (!pressedPointers.contains(event.pointer)) return;
    pressedPointers.remove(event.pointer);

    _controller.addAnimationEvent(WordCanvasAnimationEvent(
      message: _message,
      position: event.boxPosition,
      state: WordCanvasAnimationState.stampEnd,
    ));
  }
}
