import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtil {
  
  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url) {
      return http.get(url).then((http.Response response) {
          final String _response = response.body;
          final int statusCode = response.statusCode;

          if (statusCode < 200 || statusCode > 400 || json == null) {
              return _decoder.convert('{"type":"error", "text":"An error has occured, Sorry!"}');
          }
          return _decoder.convert(_response);
      });
  }

  Future<dynamic> post(String url, {Map headers, body, encoding}) {
      return http
          .post(url, body: body, headers: headers, encoding: encoding)
          .then((http.Response response) {
            
          final String _response = response.body;
          final int statusCode = response.statusCode;

          if (statusCode < 200 || statusCode > 400 || json == null) {
              return _decoder.convert('{"type":"error", "text":"An error has occured, Sorry!"}');
          }
          return _decoder.convert(_response);
      });
    }
}