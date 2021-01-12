library UHST;

class ClientConfiguration {
  final String clientToken;
  final String? sendUrl;
  final String? receiveUrl;
  ClientConfiguration(
      {required this.clientToken, this.receiveUrl, this.sendUrl});
}
