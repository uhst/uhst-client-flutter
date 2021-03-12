import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../contracts/type_definitions.dart';
import '../utils/uhst_exceptions.dart';

class NetworkClient {
  /// Returns generic [T] type from response
  /// Handles error cases
  Future<T> post<T>({required Uri uri, required FromJson<T> fromJson}) async {
    T handleResponseForFetch({required http.Response response}) {
      switch (response.statusCode) {
        case 200:
          var responseText = response.body;
          if (responseText.isEmpty)
            throw ArgumentError('response text is empty');
          var decodedBody = jsonDecode(responseText);
          return fromJson(decodedBody);
        default:
          throw NetworkError("${response.statusCode} ${response.reasonPhrase}");
      }
    }

    try {
      var response = await http.post(uri);
      return handleResponseForFetch(response: response);
    } catch (error) {
      throw NetworkUnreachable(Uri(userInfo: error.toString()));
    }
  }
}
