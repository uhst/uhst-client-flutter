library UHST;

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
}
