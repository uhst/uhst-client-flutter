part of uhst_models;

class HostConfiguration {
  HostConfiguration({
    required this.hostId,
    required this.hostToken,
    this.receiveUrl,
    this.sendUrl,
  });
  // Reason: use this as callback
  // ignore: prefer_constructors_over_static_methods
  static HostConfiguration fromJson(Map<String, dynamic> map) =>
      HostConfiguration(
        hostId: map['hostId'] ?? '',
        hostToken: map['hostToken'] ?? '',
        sendUrl: map['sendUrl'],
        receiveUrl: map['receiveUrl'],
      );
  final String hostId;
  final String hostToken;
  final String? sendUrl;
  final String? receiveUrl;
}
