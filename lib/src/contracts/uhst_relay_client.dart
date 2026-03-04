import '../models/models.dart';
import '../utils/utils.dart';

/// Handler called when relay is ready.
typedef RelayReadyHandler = void Function({required RelayStream stream});

/// Handler called when a relay message is received.
typedef RelayMessageHandler = void Function({required Message message});

/// Handler called when a relay event is received.
typedef RelayEventHandler = void Function({required RelayEvent event});

/// Handler called when a relay exception occurs.
typedef RelayExceptionHandler = void Function({
  required RelayException exception,
});

/// Abstract relay client for communication with the server.
abstract class UhstRelayClient {
  /// Initialize as a host.
  Future<HostConfiguration> initHost({String? hostId});

  /// Initialize as a client.
  Future<ClientConfiguration> initClient({required String hostId});

  /// Send a message via the relay.
  Future<dynamic> sendMessage({
    required String token,
    required dynamic message,
    String? sendUrl,
  });

  /// Subscribe to messages from the relay.
  void subscribeToMessages({
    required String token,
    required RelayReadyHandler onReady,
    required RelayExceptionHandler onException,
    required RelayMessageHandler onMessage,
    RelayEventHandler? onRelayEvent,
    String? receiveUrl,
  });
}
