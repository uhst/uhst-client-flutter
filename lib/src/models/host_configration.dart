/// Host configuration returned by the relay server.
class HostConfiguration {
  /// Creates a [HostConfiguration].
  HostConfiguration({
    required this.hostId,
    required this.hostToken,
    this.receiveUrl,
    this.sendUrl,
  });

  /// Creates a [HostConfiguration] from JSON.
  // ignore: prefer_constructors_over_static_methods
  static HostConfiguration fromJson(Map<String, dynamic> map) =>
      HostConfiguration(
        hostId: map['hostId'] ?? '',
        hostToken: map['hostToken'] ?? '',
        sendUrl: map['sendUrl'],
        receiveUrl: map['receiveUrl'],
      );

  /// The host ID.
  final String hostId;

  /// The host token.
  final String hostToken;

  /// The send URL.
  final String? sendUrl;

  /// The receive URL.
  final String? receiveUrl;
}
