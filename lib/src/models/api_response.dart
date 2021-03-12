library uhst;

class ApiResponse {
  final String url;
  ApiResponse({required this.url});

  static ApiResponse fromJson(Map<String, dynamic> map) =>
      new ApiResponse(url: map['url'] ?? '');
}
