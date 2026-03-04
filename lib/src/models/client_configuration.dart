/// Client configuration returned by the relay server.
class ClientConfiguration {
  /// Creates a [ClientConfiguration].
  ClientConfiguration({
    required this.clientToken,
    this.receiveUrl,
    this.sendUrl,
  });

  /// Creates a [ClientConfiguration] from JSON.
  // ignore: prefer_constructors_over_static_methods
  static ClientConfiguration fromJson(Map<String, dynamic> map) =>
      ClientConfiguration(
        clientToken: map['clientToken'] ?? '',
        receiveUrl: map['receiveUrl'],
        sendUrl: map['sendUrl'],
      );

  /// The client token.
  final String clientToken;

  /// The send URL.
  final String? sendUrl;

  /// The receive URL.
  final String? receiveUrl;
}
