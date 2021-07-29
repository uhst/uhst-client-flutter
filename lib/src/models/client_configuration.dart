part of uhst_models;

class ClientConfiguration {
  ClientConfiguration({
    required this.clientToken,
    this.receiveUrl,
    this.sendUrl,
  });
  // Reason: use this as callback
  // ignore: prefer_constructors_over_static_methods
  static ClientConfiguration fromJson(Map<String, dynamic> map) =>
      ClientConfiguration(
        clientToken: map['clientToken'] ?? '',
        receiveUrl: map['receiveUrl'],
        sendUrl: map['sendUrl'],
      );
  final String clientToken;
  final String? sendUrl;
  final String? receiveUrl;
}
