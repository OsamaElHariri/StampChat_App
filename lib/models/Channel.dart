import 'package:StampChat/models/Message.dart';

class Channel {
  int id;
  DateTime dateCreated;
  String topic;
  String name;
  Message lastMessage;

  Channel({this.id, this.topic, this.name, this.dateCreated, this.lastMessage});

  factory Channel.fromJson(Map map) {
    Message lastMessage;
    if (map.containsKey("last_message") && map["last_message"] != null) {
      lastMessage = Message.fromJson(map["last_message"]);
    }

    return Channel(
        id: map['id'],
        name: map['friendly_name'],
        topic: map['topic'],
        dateCreated: DateTime.parse(map['inserted_at']),
        lastMessage: lastMessage);
  }
}
