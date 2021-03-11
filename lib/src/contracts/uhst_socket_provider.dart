library uhst;

import '../models/socket_params.dart';
import 'uhst_relay_client.dart';
import 'uhst_socket.dart';

/// Provides Client or Host socket depending
/// from received configuration
abstract class UhstSocketProvider {
  /// If [clientParams] where provided then it will return Client Socket
  /// If [hostParams] where provided then it will return Host Socket
  ///
  /// Only one - [clientParams] or [hostParams]
  /// can be provided in same time
  UhstSocket createUhstSocket(
      {required UhstRelayClient relayClient,
      ClientSocketParams? clientParams,
      HostSocketParams? hostParams,
      required bool debug});
}
