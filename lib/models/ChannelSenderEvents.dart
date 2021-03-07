import 'package:StampChat/models/Member.dart';
import 'package:StampChat/models/Message.dart';

class ChannelSenderEvents {
  List<Message> messages;
  Map<int, Member> members = {};
  bool isLastChannelEvent = true;

  ChannelSenderEvents(
      {this.messages = const [],
      List<Member> members = const [],
      this.isLastChannelEvent = true}) {
    members.forEach((member) {
      this.members[member.id] = member;
    });
    _addMemberToMessages(messages);
  }

  void merge(ChannelSenderEvents senderEvents) {
    members.addAll(senderEvents.members);
    _addMessages(senderEvents.messages);
  }

  void _addMessages(List<Message> messages) {
    this.messages = [...this.messages, ...messages];
  }

  List<Message> _addMemberToMessages(List<Message> messages) {
    return messages.map((msg) {
      if (this.members.containsKey(msg.memberId)) {
        msg.member = this.members[msg.memberId];
      }
    }).toList();
  }
}
