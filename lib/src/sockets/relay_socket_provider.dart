library uhst;

import '../contracts/uhst_api_client.dart';
import '../contracts/uhst_socket.dart';
import '../contracts/uhst_socket_provider.dart';
import 'relay_socket.dart';

class RelaySocketProvider implements UhstSocketProvider {
  @override
  UhstSocket createUhstSocket(
      {required UhstApiClient apiClient,
      clientParams,
      hostParams,
      required bool debug}) {
    return RelaySocket.create(
        apiClient: apiClient,
        clientParams: clientParams,
        hostParams: hostParams,
        debug: debug);
  }
}
