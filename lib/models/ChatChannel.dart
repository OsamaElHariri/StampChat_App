import 'dart:async';

import 'package:StampChat/models/Stamp.dart';
import 'package:StampChat/services/Api.dart';
import 'package:phoenix_socket/phoenix_socket.dart';

class ChatChannel {
  PhoenixSocket _socket;
  PhoenixChannel _channel;

  StreamController<Map> _onMessageController = StreamController<Map>();
  Stream<Map> get onMessage => _onMessageController.stream;

  void connect(String topic) {
    _socket = PhoenixSocket('wss://${Api.baseUrl}/chat/socket/websocket',
        socketOptions: PhoenixSocketOptions(params: {
          "token": Api.token,
        }))
      ..connect();

    _socket.openStream.listen((event) {
      _channel = _socket.addChannel(topic: 'room:$topic');
      _channel.join();
      _channel.messages.listen((event) {
        _onMessageController.add(event.payload);
      });
    });
  }

  void addMessage(String text) {
    _channel.push("shout", {
      "message": text,
    });
  }

  void addStamp(Stamp stamp) {
    _channel.push("stamp", {
      "word": stamp.word,
      "xPos": stamp.xPos,
      "yPos": stamp.yPos,
      "strength": stamp.strength,
      "messageId": stamp.messageId,
    });
  }

  void close() {
    _onMessageController.close();
    _socket.close();
  }
}
