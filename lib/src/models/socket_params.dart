library uhst;

class HostSocketParams {
  final String token;
  final String? sendUrl;
  HostSocketParams({required this.token, this.sendUrl});
}

class ClientSocketParams {
  final String hostId;
  ClientSocketParams({required this.hostId});
}
