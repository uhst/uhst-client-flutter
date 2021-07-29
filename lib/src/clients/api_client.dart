part of uhst_clients;

class _Consts {
  static const apiUrl = 'https://api.uhst.io/v1/get-relay';
}

/// [ApiClient] Wraps [RelayClient] and is responsible for getting a
/// relayUrl from the UHST public relays directory.
class ApiClient implements UhstRelayClient {
  ApiClient() : networkClient = NetworkClient();
  NetworkClient networkClient;
  late RelayClient relayClient;

  @override
  Future<ClientConfiguration> initClient({required String hostId}) async {
    final relayUrl = await getRelayUrl(hostId: hostId);
    relayClient = RelayClient(relayUrl: relayUrl);
    return relayClient.initClient(hostId: hostId);
  }

  @override
  Future<HostConfiguration> initHost({String? hostId}) async {
    final relayUrl = await getRelayUrl(hostId: hostId);
    relayClient = RelayClient(relayUrl: relayUrl);
    return relayClient.initHost(hostId: hostId);
  }

  @override
  Future sendMessage({
    required String token,
    required dynamic message,
    String? sendUrl,
  }) =>
      relayClient.sendMessage(
        token: token,
        message: message,
        sendUrl: sendUrl,
      );

  @override
  void subscribeToMessages({
    required String token,
    required RelayReadyHandler onReady,
    required RelayExceptionHandler onException,
    required RelayMessageHandler onMessage,
    String? receiveUrl,
  }) =>
      relayClient.subscribeToMessages(
        token: token,
        onReady: onReady,
        onException: onException,
        onMessage: onMessage,
        receiveUrl: receiveUrl,
      );

  Future<String> getRelayUrl({String? hostId}) async {
    var uri = Uri.parse(_Consts.apiUrl);
    if (hostId != null) {
      final qParams = <String, String>{};
      qParams['hostId'] = hostId;
      uri = uri.replace(queryParameters: qParams);
    }

    final apiResponse = await networkClient.post(
      uri: uri,
      fromJson: ApiResponse.fromJson,
    );
    return apiResponse.url;
  }
}
