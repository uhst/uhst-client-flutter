part of uhst_models;

class HostSocketParams {
  HostSocketParams({
    required this.token,
    this.sendUrl,
  });
  final String token;
  final String? sendUrl;
}

class ClientSocketParams {
  ClientSocketParams({required this.hostId});
  final String hostId;
}
