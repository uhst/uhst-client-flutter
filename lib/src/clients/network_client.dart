import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../contracts/type_definitions.dart';
import '../utils/uhst_exceptions.dart';

class NetworkClient {
  /// Returns generic [T] type from response
  /// Handles error cases
  Future<T> post<T>({required Uri uri, required FromJson<T> fromJson}) async {
    var response;
    try {
      response = await http.post(uri);
    } catch (error) {
      throw NetworkUnreachable(error);
    }
    if (response.statusCode == 200) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw NetworkError(
          responseCode: response.statusCode, message: response.body);
    }
  }
}
