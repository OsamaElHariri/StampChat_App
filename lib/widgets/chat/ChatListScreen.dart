import 'package:StampChat/models/Channel.dart';
import 'package:StampChat/services/ChannelEventService.dart';
import 'package:StampChat/services/PushNotificationsService.dart';
import 'package:StampChat/services/auth/GoogleAuthHelper.dart';
import 'package:StampChat/widgets/chat/ActionPromptDialog.dart';
import 'package:StampChat/widgets/chat/ChatScreen.dart';
import 'package:StampChat/widgets/chat/TextPromptDialog.dart';
import 'package:StampChat/widgets/user/LoginScreen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Channel> channels;
  bool _isLoadig = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _refreshChannels();
    _initDynamicLinks();
  }

  Future<void> _refreshChannels({bool transitionToScreenLoading = true}) async {
    if (transitionToScreenLoading) {
      setState(() {
        _isLoadig = true;
      });
    }
    List<Channel> userChannels;
    bool hasError = false;
    try {
      userChannels = await ChannelEventService.getChannels();
    } catch (e) {
      hasError = true;
    }
    setState(() {
      _isLoadig = false;
      channels = userChannels;
      _hasError = hasError;
    });
  }

  void _initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        _handleChannelInvite(deepLink.path.substring(1));
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      _handleChannelInvite(deepLink.path.substring(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chats"),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String val) {
                if (val == "Logout") _logout();
              },
              itemBuilder: (BuildContext context) => ["Logout"]
                  .map((String choice) => PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      ))
                  .toList(),
            ),
          ],
        ),
        body: _isLoadig
            ? _buildLoadingState()
            : _hasError
                ? _buildErrorState()
                : _buildChannelList(channels));
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
        Text("Error Loading Chats"),
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
        Text("Loading Chats"),
      ],
    );
  }

  Widget _buildChannelList(List<Channel> channels) {
    return RefreshIndicator(
      onRefresh: () => _refreshChannels(transitionToScreenLoading: false),
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          _buildAddChannelTile(),
          Expanded(
            child: channels.isEmpty
                ? _buildNoChatsInfo()
                : ListView(
                    children: channels
                        .map((channel) => _buildChannelTile(channel))
                        .toList(),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildNoChatsInfo() {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 24, right: 16),
      child: Opacity(
        opacity: 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Looks like you are not a member of any chats"),
            Padding(padding: EdgeInsets.only(bottom: 20)),
            Text("You can create a chat using the \"+ Create Chat\" button"),
          ],
        ),
      ),
    );
  }

  Widget _buildAddChannelTile() {
    return InkWell(
      onTap: () => _promptAddChannel(),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.add),
            Padding(padding: EdgeInsets.only(left: 8)),
            Text(
              "Create Chat",
              style: Theme.of(context).accentTextTheme.headline5,
            )
          ],
        ),
      ),
    );
  }

  void _promptAddChannel() async {
    Channel channel = await showDialog<Channel>(
      context: context,
      builder: (_) => TextPromptDialog<Channel>(
        title: Text("Create a New Chat"),
        hintText: "What is this chat about?",
        callToAction: Text("LET'S GO!"),
        action: (String input) => ChannelEventService.createChannel(input),
      ),
    );

    if (channel != null) {
      setState(() {
        channels.add(channel);
      });
    }
  }

  Widget _buildChannelTile(Channel channel) {
    return InkWell(
      onTap: () => _goToChat(channel),
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              channel.name,
              style: Theme.of(context).accentTextTheme.headline5,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                channel.lastMessage == null
                    ? "This chat has no messages"
                    : channel.lastMessage.singleLineBody,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).accentTextTheme.bodyText2,
              ),
            ),
            Divider()
          ],
        ),
      ),
    );
  }

  void _goToChat(Channel channel) async {
    var nav = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatScreen(
            channel: channel,
          );
        },
      ),
    );

    if (nav is bool && nav == true) {
      _refreshChannels();
    }
  }

  void _logout() async {
    bool success = await showDialog<bool>(
      context: context,
      builder: (_) => ActionPromptDialog<bool>(
          title: Text("Logout"),
          dangerousCallToAction: true,
          callToAction: Text("YES, GOODBYE"),
          cancelAction: Text("FINE, I'LL STAY"),
          actionPrompt: Text("Is this where we say goodbye?"),
          action: () async {
            await PushNotificationsService.unregisterToken();
            await GoogleAuthHelper().signOutGoogle();
            return true;
          }),
    );

    if (success != null && success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ),
      );
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Error logging out"),
      ));
    }
  }

  void _handleChannelInvite(String topic) async {
    bool success = await showDialog<bool>(
      context: context,
      builder: (_) => ActionPromptDialog<bool>(
        title: Text("Chat Invite"),
        callToAction: Text("JOIN CHAT"),
        cancelAction: Text("NO THANKS"),
        actionPrompt: RichText(
          text: TextSpan(children: [
            TextSpan(text: "You have been invited to "),
            TextSpan(
                text: topic, style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ", do you want to join?"),
          ]),
        ),
        action: () => ChannelEventService.joinChannel(topic),
      ),
    );

    if (success != null && success) {
      _refreshChannels();
    }
  }
}
