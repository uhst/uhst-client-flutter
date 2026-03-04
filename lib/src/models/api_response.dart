/// API response wrapper.
class ApiResponse {
  /// Creates an [ApiResponse].
  ApiResponse({required this.url});

  /// Creates an [ApiResponse] from JSON.
  // ignore: prefer_constructors_over_static_methods
  static ApiResponse fromJson(Map<String, dynamic> map) =>
      ApiResponse(url: map['url'] ?? '');

  /// The URL.
  final String url;
}
