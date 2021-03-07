import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Api {
  static var baseUrl = "stampchat.tk";
  static String token = "";

  static void setToken(String t) {
    token = t;
  }

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

    final uri = Uri.https(
        baseUrl,
        path,
        queryParams?.map(
            (key, val) => MapEntry(key, val == null ? null : val.toString())));

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
    String baseUrl,
    Map<String, Object> queryParams,
    Map<String, String> headers,
  }) async {
    headers = _getHeaders(headers);

    final uri = Uri.https(baseUrl ?? Api.baseUrl, path);
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
