import 'package:StampChat/models/Message.dart';
import 'package:StampChat/widgets/chat/ChannelEventRandomElements.dart';
import 'package:StampChat/widgets/chat/InteractionMode.dart';
import 'package:StampChat/widgets/word_canvas/MessageCanvas.dart';
import 'package:StampChat/widgets/word_canvas/WordCanvasController.dart';
import 'package:flutter/material.dart';
import 'package:simple_rich_text/simple_rich_text.dart';
import 'package:spritewidget/spritewidget.dart';

class MessageTile extends StatefulWidget {
  final Message message;
  final InteractionMode interactionMode;
  final ImageMap images;
  final Function(Message, num, Offset) onTap;
  final WordCanvasController wordCanvasController;

  MessageTile({
    Key key,
    @required this.message,
    @required this.wordCanvasController,
    @required this.interactionMode,
    @required this.images,
    @required this.onTap,
  }) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  Size msgSize;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().scheduleFrameCallback((_) {
      setState(() {
        msgSize = context.size;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget msgTile = _buildMessageTile(widget.message);
    if (msgSize == null) return msgTile;
    return Stack(
      overflow: Overflow.visible,
      children: [
        Positioned(
          top: 0.0,
          left: 0.0,
          width: msgSize.width,
          height: msgSize.height,
          child: IgnorePointer(
            ignoring: widget.interactionMode == InteractionMode.input,
            child: MessageCanvas(
              images: widget.images,
              onTap: widget.onTap,
              message: widget.message,
              size: msgSize,
              controller: widget.wordCanvasController,
            ),
          ),
        ),
        IgnorePointer(
          ignoring: widget.interactionMode != InteractionMode.input,
          child: msgTile,
        ),
      ],
    );
  }

  Widget _buildMessageTile(Message msg) {
    if (msg.type == "chat_info")
      return _buildInfoMessageTile(msg);
    else
      return _buildChatMessageTile(msg);
  }

  Widget _buildInfoMessageTile(Message msg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SimpleRichText(
            text: msg.singleLineBody,
            style: Theme.of(context).accentTextTheme.bodyText1,
          ),
        ),
        Divider(height: 1),
      ],
    );
  }

  Widget _buildChatMessageTile(Message msg) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                ChannelEventRandomElements.getMemberIcon(
                    widget.message.memberId),
                color: ChannelEventRandomElements.getStampColor(
                    widget.message.memberId),
                width: 16,
                height: 16,
              ),
              Padding(padding: EdgeInsets.only(left: 4)),
              Text(
                msg.author,
                style: Theme.of(context).accentTextTheme.headline6,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SimpleRichText(
              text: msg.body,
              style: Theme.of(context).accentTextTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}
