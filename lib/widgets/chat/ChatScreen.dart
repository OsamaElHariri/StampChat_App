import 'package:StampChat/models/Channel.dart';
import 'package:StampChat/models/ChannelSenderEvents.dart';
import 'package:StampChat/models/ChatChannel.dart';
import 'package:StampChat/models/Message.dart';
import 'package:StampChat/models/Stamp.dart';
import 'package:StampChat/services/ChannelEventService.dart';
import 'package:StampChat/services/DynamicLinkService.dart';
import 'package:StampChat/services/MessageHistoryService.dart';
import 'package:StampChat/widgets/chat/ActionPromptDialog.dart';
import 'package:StampChat/widgets/chat/ChannelEventRandomElements.dart';
import 'package:StampChat/widgets/chat/InteractionMode.dart';
import 'package:StampChat/widgets/chat/ChatInputPanel.dart';
import 'package:StampChat/widgets/chat/MessageTile.dart';
import 'package:StampChat/widgets/word_canvas/WordCanvasController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChatScreen extends StatefulWidget {
  final Channel channel;

  ChatScreen({@required this.channel});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatChannel _chatChannel = ChatChannel();
  Key _listViewKey = UniqueKey();
  InteractionMode _interactionMode = InteractionMode.input;
  ScrollController _scrollController = ScrollController();
  WordCanvasController _wordCanvasController = WordCanvasController();
  TextEditingController _textEditingController = TextEditingController();
  ImageMap _images = ImageMap(rootBundle);

  bool _isLoading = true;
  bool _hasError = false;
  MessageHistoryService _messageHistoryService;

  Key _loaderKey = Key('message-horizon-loader');

  @override
  void initState() {
    super.initState();
    try {
      _chatChannel.connect(widget.channel.topic);
    } catch (e) {
      setState(() => _hasError = true);
    }
    _chatChannel.onMessage.listen(_onEvent);
    _initChatScreen();
  }

  void _initChatScreen() async {
    try {
      await _images.load([
        "assets/grunge.png",
        "assets/smoke_ring.png",
        ...ChannelEventRandomElements.stampBorders
      ]);
      var messageHistoryService =
          MessageHistoryService(channelId: widget.channel.id);
      setState(() {
        _messageHistoryService = messageHistoryService;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onEvent(Map event) {
    if (_messageHistoryService != null &&
        event != null &&
        event.containsKey("type")) {
      if (event["type"] == "message") {
        Message msg = Message.fromJson(event["data"]);
        if (_messageHistoryService.senderEvents.members
            .containsKey(msg.memberId)) {
          msg.member =
              _messageHistoryService.senderEvents.members[msg.memberId];
          print(msg.author);
        }
        setState(() {
          _messageHistoryService.senderEvents.messages.insert(0, msg);
        });
      } else if (event["type"] == "stamp") {
        Stamp stamp = Stamp.fromJson(event["data"]);
        _wordCanvasController.addStamps([stamp]);
        Message stampMessage = _messageHistoryService.senderEvents.messages
            .firstWhere((msg) => msg.id == stamp.messageId, orElse: null);
        if (stampMessage != null) stampMessage.stamps.add(stamp);
        setState(() {
          _interactionMode = InteractionMode.input;
        });
      }
    }
  }

  @override
  void deactivate() {
    _scrollController.dispose();
    _chatChannel?.close();
    _messageHistoryService?.close();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) => PopupMenuButton<String>(
              onSelected: (String val) {
                if (val == "Leave Chat") _leaveChannel();
                if (val == "Chat link") _copyChannelLink(context);
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: "Chat link",
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 4),
                      child: Icon(
                        Icons.copy,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text("Invite link"),
                  ]),
                ),
                PopupMenuItem<String>(
                  value: "Leave Chat",
                  child: Text("Leave Chat"),
                ),
              ],
            ),
          )
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
              ? _buildErrorState()
              : _buildChatScreen(),
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          size: 40,
          color: Theme.of(context).errorColor,
        ),
        Container(
          padding: EdgeInsets.only(top: 16),
        ),
        Text("Error Loading Messages"),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        Container(
          padding: EdgeInsets.only(top: 16),
        ),
        Text("Loading Messages"),
      ],
    );
  }

  Widget _buildChatScreen() {
    return StreamBuilder<ChannelSenderEvents>(
      stream: _messageHistoryService.onEvents,
      builder:
          (BuildContext context, AsyncSnapshot<ChannelSenderEvents> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).accentColor,
                  child: _buildMessagesView(snapshot.data.messages),
                ),
              ),
              ChatInputPanel(
                  key: Key('chat-input-panel'),
                  onSend: _onChatSend,
                  toggleInputMode: _toggleMode,
                  textEditingController: _textEditingController,
                  interactionMode: _interactionMode,
                  images: _images)
            ],
          );
        } else if (snapshot.hasError) {
          return _buildErrorState();
        } else {
          return _buildLoadingState();
        }
      },
    );
  }

  Future _onChatSend(String userInput) {
    _chatChannel.addMessage(userInput);
    return Future.value(true);
  }

  Future _onWordStamp(Message msg, num strength, Offset position) {
    if (_textEditingController.text.isEmpty) return Future.value(true);
    var stamp = Stamp(
        messageId: msg.id,
        word: _textEditingController.text,
        xPos: position.dx,
        yPos: position.dy,
        strength: strength);

    _chatChannel.addStamp(stamp);
    _textEditingController.clear();
    return Future.value(true);
  }

  void _toggleMode() {
    var targetMode = _interactionMode == InteractionMode.input
        ? InteractionMode.stamp
        : InteractionMode.input;
    setState(() {
      _interactionMode = targetMode;
    });
    if (_interactionMode == InteractionMode.stamp)
      FocusScope.of(context).unfocus();
  }

  Widget _buildMessagesView(List<Message> messages) {
    return ListView(
        key: _listViewKey,
        reverse: true,
        controller: _scrollController,
        children: List<Widget>.from(messages.map((message) => MessageTile(
              key: Key("message-tile-${message.id}"),
              message: message,
              interactionMode: _interactionMode,
              onTap: _onWordStamp,
              images: _images,
              wordCanvasController: _wordCanvasController,
            )))
          ..add(Builder(
              builder: (BuildContext context) => _buildChatHorizon(context))));
  }

  Widget _buildChatHorizon(BuildContext context) {
    if (_messageHistoryService.hasMoreMessages) {
      return VisibilityDetector(
        key: _loaderKey,
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction > 0) {
            _messageHistoryService?.getChannelSenderEvents();
          }
        },
        child: Container(
          padding: EdgeInsets.all(12),
          child: Center(
            child: SizedBox(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
              height: 24,
              width: 24,
            ),
          ),
        ),
      );
    } else {
      return Container(
        child: Opacity(
          opacity: 0.5,
          child: Padding(
            padding: EdgeInsets.only(top: 12, bottom: 8, left: 16, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'This is the very beginning of the chat "${widget.channel.name}"'),
                Padding(padding: EdgeInsets.only(bottom: 20)),
                Text("Invite others to this chat by sharing the chat link."),
                Padding(padding: EdgeInsets.only(bottom: 4)),
                Text("Get the invite link using this button"),
                Padding(padding: EdgeInsets.only(bottom: 8)),
                RaisedButton(
                  onPressed: () => _copyChannelLink(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 4),
                        child: Icon(
                          Icons.copy,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text("Copy chat invite link"),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 8)),
                Row(
                  children: [
                    Text("The link is also available in the "),
                    Icon(Icons.more_vert),
                    Text(" menu"),
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.arrow_downward_rounded),
                    Text("You can stamp starting here"),
                    Icon(Icons.arrow_downward_rounded),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  void _leaveChannel() async {
    bool success = await showDialog<bool>(
      context: context,
      builder: (_) => ActionPromptDialog<bool>(
        title: Text("Leave the Chat"),
        callToAction: Text("YES, I'M OUT"),
        dangerousCallToAction: true,
        cancelAction: Text("NEVERMIND"),
        actionPrompt: RichText(
          text: TextSpan(children: [
            TextSpan(text: "You really want to leave "),
            TextSpan(
                text: "${widget.channel.name}",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: "?"),
          ]),
        ),
        action: () => ChannelEventService.leaveChannel(widget.channel),
      ),
    );

    if (success != null && success) {
      Navigator.of(context).pop(true);
    }
  }

  void _copyChannelLink(BuildContext context) async {
    Uri linkUri = await DynamicLinkService.createLink(widget.channel);
    Clipboard.setData(ClipboardData(text: linkUri.toString()));
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Link copied!"),
      action: SnackBarAction(
        label: "X",
        onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
      ),
    ));
  }
}
