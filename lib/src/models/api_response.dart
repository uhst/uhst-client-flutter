part of uhst_models;

class ApiResponse {
  ApiResponse({required this.url});

  // Reason: use this as callback
  // ignore: prefer_constructors_over_static_methods
  static ApiResponse fromJson(Map<String, dynamic> map) =>
      ApiResponse(url: map['url'] ?? '');
  final String url;
}
