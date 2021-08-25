part of uhst_contracts;

typedef RelayReadyHandler = void Function({required RelayStream stream});
typedef RelayMessageHandler = void Function({required Message message});
typedef RelayEventHandler = void Function({required Message message});

typedef RelayExceptionHandler = void Function({
  required RelayException exception,
});

abstract class UhstRelayClient {
  Future<HostConfiguration> initHost({String? hostId});
  Future<ClientConfiguration> initClient({required String hostId});
  Future<dynamic> sendMessage({
    required String token,
    required dynamic message,
    String? sendUrl,
  });
  void subscribeToMessages({
    required String token,
    required RelayReadyHandler onReady,
    required RelayExceptionHandler onException,
    required RelayMessageHandler onMessage,
    String? receiveUrl,
  });
}
