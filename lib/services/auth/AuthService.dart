import 'dart:convert';

import 'package:StampChat/models/User.dart';
import 'package:StampChat/services/Api.dart';
import 'package:StampChat/services/auth/AuthRequest.dart';
import 'package:StampChat/services/auth/UserToken.dart';

class AuthService {
  static final _prefixPath = "/auth";

  static Future<UserToken> login(AuthRequest authReq) async {
    var json =
        await Api.post('$_prefixPath/login', queryParams: authReq.toMap());
    Map parsedJson = jsonDecode(json.body);

    User user = User.fromJson(parsedJson);
    UserToken userToken = UserToken(token: parsedJson['token'], user: user);
    Api.setToken(userToken.token);
    return userToken;
  }

  static Future refreshToken() async {
    var json = await Api.post('$_prefixPath/refresh',
        queryParams: {"token": Api.token});
    Map parsedJson = jsonDecode(json.body);

    String token = parsedJson["token"];
    Api.setToken(token);
    return token;
  }
}
