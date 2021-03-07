import 'dart:async';

import 'package:StampChat/models/ChannelSenderEvents.dart';
import 'package:StampChat/services/ChannelEventService.dart';

class MessageHistoryService {
  bool hasMoreMessages = true;
  int channelId;
  ChannelSenderEvents senderEvents;

  bool _isLoading = false;

  StreamController<ChannelSenderEvents> _onEventsController =
      StreamController<ChannelSenderEvents>.broadcast();
  Stream<ChannelSenderEvents> get onEvents => _onEventsController.stream;

  MessageHistoryService({this.channelId, this.senderEvents}) {
    if (senderEvents == null)
      senderEvents = ChannelSenderEvents(isLastChannelEvent: false);
    hasMoreMessages = !senderEvents.isLastChannelEvent;
    getChannelSenderEvents();
  }

  Future<void> getChannelSenderEvents() async {
    if (_isLoading || !hasMoreMessages) return;

    var lastMessageId =
        senderEvents.messages.isEmpty ? null : senderEvents.messages.last.id;
    _isLoading = true;
    try {
      var events = await ChannelEventService.getChannelSenderEvents(channelId,
          lastMessageId: lastMessageId);

      hasMoreMessages = !events.isLastChannelEvent;
      senderEvents.merge(events);

      _onEventsController.add(senderEvents);
    } catch (e) {
      _onEventsController.addError("Failed to load messages");
    }
    _isLoading = false;
  }

  void close() {
    _onEventsController.close();
  }
}
