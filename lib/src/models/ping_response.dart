/// Ping response from relay server.
class PingResponse {
  /// Creates a [PingResponse].
  PingResponse({required this.pong});

  /// Creates a [PingResponse] from JSON.
  // ignore: prefer_constructors_over_static_methods
  static PingResponse fromJson(Map<String, dynamic> map) =>
      PingResponse(pong: map['pong']);

  /// The pong timestamp.
  final int? pong;
}
