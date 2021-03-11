library uhst;

import 'relay_clients/relay_client.dart';
import 'contracts/uhst_relay_client.dart';
import 'contracts/uhst_socket.dart';
import 'contracts/uhst_socket_provider.dart';
import 'hosts/uhst_host.dart';
import 'models/socket_params.dart';
import 'sockets/relay_socket_provider.dart';

/// Provides a way to init Client [UhstSocket] and [UhstHost]
///
/// For server you can use ready to go
/// [Uhst Node Server](https://github.com/uhst/uhst-server-node)
class Uhst {
  /// Deafult Fallback URL to a UHST Relay (server)
  /// if [relayUrl] is not defined
  static final String _uhstRelayUrl = "https://demo.uhst.io/";

  /// An Relay client for communication with the server,
  /// normally used for testing or if implementing
  /// [UhstRelayClient | custom protocol].
  late UhstRelayClient _relayClient;

  /// Set to true and subscribe to "diagnostic" to
  /// receive events from [UhstSocket].
  late bool _debug;

  /// [UhstSocketProvider] is a provider for [UhstSocket]
  late UhstSocketProvider _socketProvider;

  /// [relayUrl] is a server url [String], implementing the uhst protocol.
  ///
  /// For server you can use ready to go
  /// [Uhst Node Server](https://github.com/uhst/uhst-server-node)
  ///
  /// [relayClient] is a standard host and client provider which used
  /// to subscribe to event source, send messages and init [UhstHost]
  /// and Client [UhstSocket]
  ///
  /// If no [relayClient] is provided or [relayUrl] is not defined in [relayClient]
  /// then [uhst_Relay_URL] will be used.
  ///
  /// If both [relayClient] and [relayUrl] are defined,
  /// then [relayClient] will be used.
  ///
  /// Use [debug] = true to turn on debug messages
  /// on stream events
  Uhst(
      {String? relayUrl,
      bool? debug,
      UhstRelayClient? relayClient,
      RelaySocketProvider? socketProvider}) {
    _debug = debug ?? false;

    var definedRelayUrl = relayUrl ?? _uhstRelayUrl;
    _relayClient = relayClient ?? RelayClient(relayUrl: definedRelayUrl);
    _socketProvider = socketProvider ?? RelaySocketProvider();
  }

  /// Returns [UhstSocket] which able to:
  /// - subscribes to one [UhstHost]
  /// - listen [UhstHost] messages
  /// - send messages to [UhstHost]
  UhstSocket join({required String hostId}) {
    var clientParams = ClientSocketParams(hostId: hostId);
    return _socketProvider.createUhstSocket(
        relayClient: _relayClient, clientParams: clientParams, debug: _debug);
  }

  /// Returns [UhstHost] which able to:
  /// - listen messages from [UhstSocket]
  /// - broadcast messages to all subscsribed Client [UhstSocket]
  UhstHost host({String? hostId}) {
    var host = UhstHost.create(
        relayClient: _relayClient,
        socketProvider: _socketProvider,
        hostId: hostId,
        debug: _debug);
    return host;
  }
}
