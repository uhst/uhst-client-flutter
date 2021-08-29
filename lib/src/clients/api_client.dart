part of uhst_clients;

/// [ApiClient] Wraps [RelayClient] and is responsible for getting a
/// relayUrl from the UHST public relays directory.
class ApiClient implements UhstRelayClient {
  ApiClient()
      : relayUrlsProvider = const RelayUrlsProvider(
          networkClient: NetworkClient(),
        );
  RelayUrlsProvider relayUrlsProvider;
  late RelayClient relayClient;

  @override
  Future<ClientConfiguration> initClient({required String hostId}) async {
    final relayUrl = await relayUrlsProvider.getBestRelayUrl(hostId);
    relayClient = RelayClient(
      relayUrl: relayUrl,
      networkClient: const NetworkClient(),
    );
    return relayClient.initClient(hostId: hostId);
  }

  @override
  Future<HostConfiguration> initHost({String? hostId}) async {
    final relayUrl = await relayUrlsProvider.getBestRelayUrl(hostId);
    relayClient = RelayClient(
      relayUrl: relayUrl,
      networkClient: const NetworkClient(),
    );
    return relayClient.initHost(hostId: hostId);
  }

  @override
  Future sendMessage({
    required String token,
    required dynamic message,
    String? sendUrl,
  }) async =>
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
    RelayEventHandler? onRelayEvent,
    String? receiveUrl,
  }) =>
      relayClient.subscribeToMessages(
        token: token,
        onReady: onReady,
        onException: onException,
        onMessage: onMessage,
        onRelayEvent: onRelayEvent,
        receiveUrl: receiveUrl,
      );
}
