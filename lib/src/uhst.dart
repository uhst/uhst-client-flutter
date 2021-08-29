import 'clients/clients.dart';
import 'contracts/contracts.dart';
import 'hosts/hosts.dart';
import 'models/models.dart';
import 'sockets/sockets.dart';

/// Provides a way to init Client [UhstSocket] and [UhstHost]
///
/// For relay server you can use ready to go
/// [UHST Node Server](https://github.com/uhst/uhst-server-node)
class UHST {
  /// [relayUrl] is a relay url [String], implementing the uhst protocol.
  ///
  /// For server you can use ready to go
  /// [UHST Node Server](https://github.com/uhst/uhst-server-node)
  ///
  /// [relayClient] is a standard host and client provider which used
  /// to subscribe to event source, send messages and init [UhstHost]
  /// and Client [UhstSocket]
  ///
  /// If no [relayClient] is provided and [relayUrl] is not defined
  /// then a public relay will be chosen by the API.
  ///
  /// If both [relayClient] and [relayUrl] are defined,
  /// then [relayClient] will be used.
  ///
  /// Use [debug] = true to turn on debug messages
  /// on stream events
  UHST({
    String? relayUrl,
    bool? debug,
    UhstRelayClient? relayClient,
    RelaySocketProvider? socketProvider,
  }) {
    _debug = debug ?? false;

    if (relayClient != null) {
      _relayClient = relayClient;
    } else if (relayUrl != null) {
      _relayClient = RelayClient(
        relayUrl: relayUrl,
      );
    } else {
      _relayClient = ApiClient();
    }
    _socketProvider = socketProvider ?? RelaySocketProvider();
  }

  /// Relay client for communication with the server,
  /// normally used for testing or if implementing
  /// [UhstRelayClient | custom protocol].
  late UhstRelayClient _relayClient;

  /// Set to true and subscribe to "diagnostic" to
  /// receive events from [UhstSocket].
  late bool _debug;

  /// [UhstSocketProvider] is a provider for [UhstSocket]
  late UhstSocketProvider _socketProvider;

  /// Returns [UhstSocket] which able to:
  /// - subscribes to one [UhstHost]
  /// - listen [UhstHost] messages
  /// - send messages to [UhstHost]
  UhstSocket join({required String hostId}) {
    final clientParams = ClientSocketParams(hostId: hostId);
    return _socketProvider.createUhstSocket(
      relayClient: _relayClient,
      clientParams: clientParams,
      debug: _debug,
    );
  }

  /// Returns [UhstHost] which able to:
  /// - listen messages from [UhstSocket]
  /// - broadcast messages to all subscsribed Client [UhstSocket]
  UhstHost host({String? hostId}) {
    final host = UhstHost.create(
      relayClient: _relayClient,
      socketProvider: _socketProvider,
      hostId: hostId,
      debug: _debug,
    );
    return host;
  }
}
