import 'dart:async';

import 'package:StampChat/widgets/chat/ChatTutorialDialog.dart';
import 'package:StampChat/widgets/chat/InteractionMode.dart';
import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';

class ChatInputPanel extends StatefulWidget {
  final Future Function(String) onSend;
  final TextEditingController textEditingController;
  final void Function() toggleInputMode;
  final InteractionMode interactionMode;
  final ImageMap images;

  ChatInputPanel({
    Key key,
    @required this.onSend,
    @required this.toggleInputMode,
    @required this.textEditingController,
    @required this.interactionMode,
    @required this.images,
  }) : super(key: key);

  @override
  _ChatInputPanelState createState() => _ChatInputPanelState();
}

class _ChatInputPanelState extends State<ChatInputPanel> {
  final maxStampLength = 5;
  bool _isSendEnabled = false;

  bool _showStamp = true;
  Timer _timer;

  int _textCount = 0;

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(() {
      int newCount = widget.textEditingController.text.characters.length;
      if (_textCount == newCount) return;
      _textCount = newCount;
      _timer?.cancel();
      if (widget.textEditingController.text.isEmpty) {
        setState(() {
          _isSendEnabled = false;
          _showStamp = true;
        });
      } else {
        _timer = Timer(Duration(milliseconds: 600), () {
          if (mounted) setState(() => _showStamp = true);
        });
        setState(() {
          _showStamp = newCount > maxStampLength;
          _isSendEnabled = true;
        });
      }
    });
  }

  @override
  void deactivate() {
    _timer?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget panel = widget.interactionMode == InteractionMode.input
        ? _buildInputPanel()
        : _buildStampPanel();
    return Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: panel,
        ));
  }

  Widget _buildStampPanel() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Text(
            "Tap on the chat to stamp!",
            style: Theme.of(context)
                .accentTextTheme
                .headline6
                .copyWith(color: Theme.of(context).accentColor),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 4)),
        RaisedButton(
          onPressed: widget.toggleInputMode,
          child: Text("Cancel"),
        )
      ],
    );
  }

  Widget _buildInputPanel() {
    const buttonWidth = 40.0;
    var textLength = widget.textEditingController.text.characters.length;
    var canStampWord = textLength > 0 && textLength <= maxStampLength;
    var visibleIcon = Matrix4.translationValues(0, 0, 0);
    var hiddenIcon = Matrix4.translationValues(0, -40, 0);
    return Row(
      children: [
        ButtonTheme(
          minWidth: buttonWidth,
          child: RaisedButton(
            padding: EdgeInsets.zero,
            color: Theme.of(context).accentColor,
            disabledColor: Theme.of(context).accentColor,
            onPressed: canStampWord
                ? () => widget.toggleInputMode()
                : textLength == 0
                    ? _showChatTutorial
                    : null,
            child: Container(
              width: buttonWidth,
              height: 36,
              child: ClipRect(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      transform: _showStamp && textLength > 0
                          ? visibleIcon
                          : hiddenIcon,
                      child: Image.asset(
                        'assets/icons/stamp.png',
                        color: Theme.of(context).primaryColor,
                        width: 24,
                        height: 24,
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      transform: _showStamp && textLength > maxStampLength
                          ? visibleIcon
                          : hiddenIcon,
                      child: Image.asset(
                        'assets/icons/stop_sign.png',
                        color: Theme.of(context).errorColor,
                        width: 32,
                        height: 32,
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      transform: _showStamp && textLength == 0
                          ? visibleIcon
                          : hiddenIcon,
                      child: Center(
                        child: Text(
                          "?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      transform: !_showStamp
                          ? visibleIcon
                          : Matrix4.translationValues(0, 40, 0),
                      child: _buildTextCountIndicator(textLength),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(left: 4)),
        Expanded(
          child: TextField(
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(6.0),
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              hintText: "Type your message",
            ),
            controller: widget.textEditingController,
          ),
        ),
        Padding(padding: EdgeInsets.only(left: 8)),
        RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 8),
          color: Theme.of(context).accentColor,
          child: Icon(Icons.send, color: Theme.of(context).primaryColor),
          onPressed: _isSendEnabled ? _onSendPressed : null,
        )
      ],
    );
  }

  void _onSendPressed() async {
    setState(() => _isSendEnabled = false);
    var success = await _envokeOnSendCallback();
    if (success) {
      widget.textEditingController.clear();
    } else {
      setState(() => _isSendEnabled = true);
    }
  }

  Future<bool> _envokeOnSendCallback() async {
    try {
      await widget.onSend(widget.textEditingController.text);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildTextCountIndicator(int textLength) {
    var visibleIcon = Matrix4.translationValues(0, 0, 0);
    var hiddenIcon = Matrix4.translationValues(0, 40, 0);
    List<Widget> children = List.generate(maxStampLength, (int index) {
      var count = index + 1;
      return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: count == textLength ? visibleIcon : hiddenIcon,
        child: Center(
          child: Text(
            "$count",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    });

    children.add(AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transform: textLength == 0 || textLength > maxStampLength
          ? visibleIcon
          : hiddenIcon,
      child: Center(
        child: Icon(
          Icons.close,
          color: Theme.of(context).primaryColor,
        ),
      ),
    ));

    return Stack(
      children: children,
    );
  }

  void _showChatTutorial() {
    showDialog<bool>(
        context: context,
        builder: (_) => ChatTutorialDialog(images: widget.images));
  }
}
