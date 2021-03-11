library uhst;

import '../contracts/uhst_relay_client.dart';
import '../contracts/uhst_socket.dart';
import '../contracts/uhst_socket_provider.dart';
import 'relay_socket.dart';

class RelaySocketProvider implements UhstSocketProvider {
  @override
  UhstSocket createUhstSocket(
      {required UhstRelayClient relayClient,
      clientParams,
      hostParams,
      required bool debug}) {
    return RelaySocket.create(
        relayClient: relayClient,
        clientParams: clientParams,
        hostParams: hostParams,
        debug: debug);
  }
}
