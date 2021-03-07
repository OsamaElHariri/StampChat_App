import 'dart:math';

import 'package:StampChat/models/Message.dart';
import 'package:StampChat/models/Stamp.dart';
import 'package:StampChat/widgets/word_canvas/MessageCanvas.dart';
import 'package:StampChat/widgets/word_canvas/WordCanvasController.dart';
import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';

class ChatTutorialDialog extends StatefulWidget {
  final ImageMap images;
  ChatTutorialDialog({this.images});

  @override
  _ChatTutorialDialogState createState() => _ChatTutorialDialogState();
}

class _ChatTutorialDialogState extends State<ChatTutorialDialog> {
  Key _stampAreaKey = Key('init-tutorial-stamp-area');

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().scheduleFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) setState(() => _stampAreaKey = Key('tutorial-stamp-area'));
    });
  }

  @override
  Widget build(BuildContext context) {
    var normalTextStyle = TextStyle(fontSize: 16);
    var strongTextStyle = normalTextStyle.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    return AlertDialog(
      key: Key('chat-tutorial-dialog'),
      contentPadding: EdgeInsets.all(16),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Type it  ", style: strongTextStyle),
                      Text("In the text field", style: normalTextStyle),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 20)),
                  Row(
                    children: [
                      Text("Tap it  ", style: strongTextStyle),
                      Image.asset(
                        'assets/icons/stamp.png',
                        color: Theme.of(context).accentColor,
                        width: 18,
                        height: 18,
                      ),
                      Text(" The stamp button", style: normalTextStyle),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 20)),
                  Row(
                    children: [
                      Text("Stamp it  ", style: strongTextStyle),
                      Text("On the chat messages", style: normalTextStyle),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 12)),
                  _buildStampTrainingArea(context),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 8)),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Padding(padding: EdgeInsets.only(left: 8)),
                Expanded(
                  child: RaisedButton(
                    textColor: Theme.of(context).primaryColor,
                    color: Theme.of(context).accentColor,
                    child: Text("GOT IT"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStampTrainingArea(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 112;
    var height = 80.0;

    var controller = WordCanvasController();
    Message dummyMessage = Message(id: Random().nextInt(100));
    List<String> words = [
      "WOW",
      "lol",
      "dunno",
      "HAHA",
      "Huh??",
      "k.",
      "YEAH",
      "nope"
    ];
    return Center(
      child: ClipRRect(
        child: Container(
          width: width,
          height: height,
          color: Theme.of(context).accentColor,
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: 0.15,
                  child: Text(
                    "TRY TO STAMP",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              MessageCanvas(
                key: _stampAreaKey,
                message: dummyMessage,
                images: widget.images,
                size: Size(width, height),
                controller: controller,
                onTap: (Message msg, num strength, Offset position) {
                  var word = words[Random().nextInt(words.length)];
                  controller.addStamps([
                    Stamp(
                        id: Random().nextInt(100),
                        memberId: Random().nextInt(100),
                        messageId: dummyMessage.id,
                        strength: strength,
                        xPos: position.dx,
                        yPos: position.dy,
                        word: word),
                  ]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
