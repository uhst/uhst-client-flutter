/// Parameters for host socket initialization.
class HostSocketParams {
  /// Creates a [HostSocketParams].
  HostSocketParams({
    required this.token,
    required this.clientId,
    this.sendUrl,
  });

  /// The token.
  final String token;

  /// The client ID.
  final String clientId;

  /// The send URL.
  final String? sendUrl;
}

/// Parameters for client socket initialization.
class ClientSocketParams {
  /// Creates a [ClientSocketParams].
  ClientSocketParams({required this.hostId});

  /// The host ID.
  final String hostId;
}
