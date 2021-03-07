import 'dart:async';

import 'package:StampChat/services/Api.dart';
import 'package:StampChat/services/auth/AuthService.dart';

class TokenRefresher {
  static final TokenRefresher _singleton = TokenRefresher._internal();

  factory TokenRefresher() => _singleton;

  TokenRefresher._internal() {
    Timer.periodic(new Duration(minutes: 20), (timer) {
      if (Api.token.isNotEmpty) AuthService.refreshToken();
    });
  }
}
