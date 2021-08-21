part of uhst_models;

class HostSocketParams {
  HostSocketParams({required this.token, required this.clientId, this.sendUrl});
  final String token;
  final String clientId;
  final String? sendUrl;
}

class ClientSocketParams {
  ClientSocketParams({required this.hostId});
  final String hostId;
}
