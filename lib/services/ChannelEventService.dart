import 'dart:convert';

import 'package:StampChat/models/Channel.dart';
import 'package:StampChat/models/ChannelSenderEvents.dart';
import 'package:StampChat/models/Member.dart';
import 'package:StampChat/models/Message.dart';
import 'package:StampChat/services/Api.dart';

class ChannelEventService {
  static final _prefixPath = "/chat";

  static Future<ChannelSenderEvents> getChannelSenderEvents(int channelId,
      {int lastMessageId}) async {
    var json = await Api.get('$_prefixPath/channels/$channelId/events',
        queryParams: {"last_message_id": lastMessageId});

    Map eventJson = jsonDecode(json.body)["data"];
    bool isLastMessage = eventJson["is_last_message"] ?? true;
    List messagesJson = eventJson["messages"];
    List<Message> messages =
        messagesJson.map((json) => Message.fromJson(json)).toList();

    List membersJson = eventJson["members"];
    List<Member> members =
        membersJson.map((json) => Member.fromJson(json)).toList();

    return ChannelSenderEvents(
      isLastChannelEvent: isLastMessage,
      messages: messages,
      members: members,
    );
  }

  static Future<List<Channel>> getChannels() async {
    var json = await Api.get('$_prefixPath/channels');
    Map parsedJson = jsonDecode(json.body);
    List channelsJson = parsedJson["data"];
    List<Channel> channels =
        channelsJson.map((json) => Channel.fromJson(json)).toList();
    return channels;
  }

  static Future<Channel> createChannel(String name) async {
    var json = await Api.post('$_prefixPath/channels',
        queryParams: {"channel_name": name});
    Map parsedJson = jsonDecode(json.body);
    Map channelJson = parsedJson["data"];
    Channel channel = Channel.fromJson(channelJson);
    return channel;
  }

  static Future<bool> leaveChannel(Channel channel) async {
    await Api.post('$_prefixPath/channels/leave', queryParams: {
      "channel_id": channel.id,
    });
    return true;
  }

  static Future<bool> joinChannel(String topic) async {
    await Api.post('$_prefixPath/channels/join', queryParams: {
      "topic": topic,
    });
    return true;
  }
}
