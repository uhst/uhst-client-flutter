part of uhst_sockets;

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
