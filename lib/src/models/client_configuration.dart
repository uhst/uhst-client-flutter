library uhst;

class ClientConfiguration {
  final String clientToken;
  final String? sendUrl;
  final String? receiveUrl;
  ClientConfiguration(
      {required this.clientToken, this.receiveUrl, this.sendUrl});

  static ClientConfiguration fromJson(Map<String, String> map) =>
      new ClientConfiguration(
          clientToken: map['clientToken'] ?? '',
          receiveUrl: map['receiveUrl'],
          sendUrl: map['sendUrl']);
}
