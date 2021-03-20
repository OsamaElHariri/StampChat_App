import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Api {
  static var baseUrl = "192.168.2.140:8080";
  static String token = "";

  static void setToken(String t) {
    token = t;
  }

  // Change to wss if the server has SSL configured
  static String get chatUrl => "ws://${Api.baseUrl}/chat/socket/websocket";

  // Change to Uri.https() if the server is configured to accept https requests
  static _generateUri(String base, String path,
          {Map<String, Object> queryParams}) =>
      Uri.http(
          baseUrl,
          path,
          queryParams?.map((key, val) =>
              MapEntry(key, val == null ? null : val.toString())));

  static Map<String, String> _getHeaders(Map<String, String> headers) {
    headers = headers ?? Map<String, String>.from({});
    headers[HttpHeaders.contentTypeHeader] = "application/json";

    if (token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = "Bearer $token";
    }
    return headers;
  }

  static Future<http.Response> get(
    String path, {
    Map<String, Object> queryParams,
    Map<String, String> headers,
  }) async {
    headers = _getHeaders(headers);
    final uri = _generateUri(baseUrl, path, queryParams: queryParams);

    print(uri);
    print(headers);
    print(queryParams);
    var res = await http.get(uri, headers: headers);
    print("STATUS ${res.statusCode} - GET - $uri");
    if (res.statusCode >= 400) {
      throw "Server error";
    }
    print(res.body);
    return res;
  }

  static Future<http.Response> post(
    String path, {
    Map<String, Object> queryParams,
    Map<String, String> headers,
  }) async {
    headers = _getHeaders(headers);

    final uri = _generateUri(baseUrl, path);
    print(uri);
    print(headers);
    print(queryParams);
    var res = await http.post(
      uri,
      body: jsonEncode(queryParams),
      headers: headers,
    );
    print("STATUS ${res.statusCode} - POST - $uri");
    if (res.statusCode >= 400) {
      throw "Server error";
    }
    print(res.body);
    return res;
  }
}
