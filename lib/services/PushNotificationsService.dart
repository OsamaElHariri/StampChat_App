import 'dart:async';
import 'dart:convert';

import 'package:StampChat/services/Api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsService {
  static String _prefixPath = "/notifications";

  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static bool _isInitialized = false;

  static StreamController<Map<String, Object>> _onMessageController =
      StreamController<Map<String, Object>>();
  static Stream<Map<String, Object>> get onMessage =>
      _onMessageController.stream;

  static StreamController<Map<String, Object>> _onResumeController =
      StreamController<Map<String, Object>>();
  static Stream<Map<String, Object>> get onResume => _onResumeController.stream;

  static void init() {
    if (_isInitialized) return;
    _firebaseMessaging.configure(
      onMessage: (message) async {
        print("PUSH NOTIFICATION MESSAGE");
        print(message);
        _onMessageController.add(message);
      },
      onResume: (message) async {
        print("PUSH NOTIFICATION ON RESUME");
        print(message);
        _onResumeController.add(message);
      },
    );
  }

  static Future<String> getToken() => _firebaseMessaging.getToken();

  static Future registerToken(String notificationToken) async {
    var json = await Api.post('$_prefixPath/register',
        queryParams: {"token": notificationToken});
    Map parsedJson = jsonDecode(json.body);
    return parsedJson;
  }

  static Future unregisterToken() async {
    await Api.post('$_prefixPath/register',
        queryParams: {"token": await getToken()});
    return true;
  }

  void destroy() {
    _onMessageController.close();
    _onResumeController.close();
  }
}
