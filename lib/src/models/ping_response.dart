part of uhst_models;

class PingResponse {
  PingResponse({required this.pong});

  // Reason: use this as callback
  // ignore: prefer_constructors_over_static_methods
  static PingResponse fromJson(Map<String, dynamic> map) =>
      PingResponse(pong: map['pong']);
  final int? pong;
}
