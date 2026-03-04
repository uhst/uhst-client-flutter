import '../models/models.dart';
import 'uhst_relay_client.dart';
import 'uhst_socket.dart';

/// Provides Client or Host socket depending
/// from received configuration.
abstract class UhstSocketProvider {
  /// If [clientParams] are provided then it will return Client Socket.
  /// If [hostParams] are provided then it will return Host Socket.
  ///
  /// Only one - [clientParams] or [hostParams]
  /// can be provided at the same time.
  UhstSocket createUhstSocket({
    required bool debug,
    required UhstRelayClient relayClient,
    ClientSocketParams? clientParams,
    HostSocketParams? hostParams,
  });
}
