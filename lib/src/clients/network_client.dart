part of uhst_clients;

class NetworkClient {
  /// Returns generic [T] type from response
  /// Handles error cases
  Future<T> post<T>({
    required Uri uri,
    required FromJson<T> fromJson,
  }) async {
    http.Response response;
    try {
      response = await http.post(uri);
    } on Exception catch (error) {
      throw NetworkUnreachable(error);
    }
    if (response.statusCode == 200) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw NetworkException(
        responseCode: response.statusCode,
        message: response.body,
      );
    }
  }
}
