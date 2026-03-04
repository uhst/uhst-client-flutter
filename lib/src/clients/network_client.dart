import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../utils/utils.dart';

/// Low-level HTTP networking client.
@immutable
class NetworkClient {
  /// Creates a [NetworkClient].
  const NetworkClient();

  /// Returns generic [T] type from response.
  /// Handles error cases.
  Future<T> post<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    http.Response response;
    try {
      var uri = Uri.parse(url);
      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters);
      }
      response = await http.post(uri);
    } on Exception catch (error) {
      throw NetworkUnreachable(error);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw NetworkException(
        responseCode: response.statusCode,
        message: response.body,
      );
    }
  }

  /// Returns generic [T] type from response.
  /// Handles error cases.
  Future<T> get<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    http.Response response;
    try {
      var uri = Uri.parse(url);
      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters);
      }
      response = await http.get(uri);
    } on Exception catch (error) {
      throw NetworkUnreachable(error);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw NetworkException(
        responseCode: response.statusCode,
        message: response.body,
      );
    }
  }
}
