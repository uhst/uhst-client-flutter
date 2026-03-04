import '../contracts/contracts.dart';
import '../models/models.dart';
import 'relay_socket.dart';

/// Factory for creating [RelaySocket] instances.
class RelaySocketProvider implements UhstSocketProvider {
  @override
  UhstSocket createUhstSocket({
    required UhstRelayClient relayClient,
    required bool debug,
    ClientSocketParams? clientParams,
    HostSocketParams? hostParams,
  }) =>
      RelaySocket.create(
        relayClient: relayClient,
        clientParams: clientParams,
        hostParams: hostParams,
        debug: debug,
      );
}
