library uhst;

class HostConfiguration {
  final String hostId;
  final String hostToken;
  final String? sendUrl;
  final String? receiveUrl;
  HostConfiguration(
      {required this.hostId,
      required this.hostToken,
      this.receiveUrl,
      this.sendUrl});

  static HostConfiguration fromJson(Map<String, dynamic> map) =>
      new HostConfiguration(
          hostId: map['hostId'] ?? '',
          hostToken: map['hostToken'] ?? '',
          sendUrl: map['sendUrl'],
          receiveUrl: map['receiveUrl']);
}
