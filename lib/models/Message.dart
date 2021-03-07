import 'package:StampChat/models/Member.dart';
import 'package:StampChat/models/Stamp.dart';

class Message {
  DateTime dateCreated;
  int id;
  String body;
  String type;
  num memberId;
  Member member;
  List<Stamp> stamps;

  String get author => member?.user?.name ?? "Anonymous";
  String get singleLineBody => type == "chat_info" ? body : "$author: $body";

  Message({
    this.id,
    this.body,
    this.dateCreated,
    this.memberId,
    this.member,
    this.type,
    this.stamps,
  });

  factory Message.fromJson(Map map) {
    Member member;
    if (map.containsKey("member") && map["member"] != null) {
      member = Member.fromJson(map["member"]);
    }

    List<Stamp> stamps = [];
    if (map.containsKey("stamps") && map["stamps"] != null) {
      List stampsJson = map["stamps"];
      stamps = stampsJson.map((s) => Stamp.fromJson(s)).toList();
    }

    return Message(
      id: map['id'],
      body: map['body'],
      dateCreated: map['dateCreated'],
      memberId: map['member_id'],
      type: map['type'],
      member: member,
      stamps: stamps,
    );
  }
}
