library uhst;

import 'api_client.dart';
import 'contracts/uhst_api_client.dart';
import 'contracts/uhst_socket.dart';
import 'contracts/uhst_socket_provider.dart';
import 'models/socket_params.dart';
import 'relay_socket_provider.dart';
import 'uhst_host.dart';

/// Provides a way to init Client [UhstSocket] and [UhstHost]
class Uhst {
  /// Deafult Fallback URL to a uhst API (server)
  /// if [apiUrl] is not defined
  static final String _uhstApiUrl = "https://demo.uhst.io/";

  /// An API client for communication with the server,
  /// normally used for testing or if implementing
  /// [UhstApiClient | custom protocol].
  late UhstApiClient _apiClient;

  /// Set to true and subscribe to "diagnostic" to
  /// receive events from [UhstSocket].
  late bool _debug;

  /// [UhstSocketProvider] is a provider for [UhstSocket]
  late UhstSocketProvider _socketProvider;

  /// [apiUrl] is a server url [String], implementing the uhst protocol.
  ///
  /// For server you can use ready to go
  /// [Uhst Node Server](https://github.com/uhst/uhst-server-node)
  ///
  /// [apiClient] is a standard host and client provider which used
  /// to subscribe to event source, send messages and init [UhstHost]
  /// and Client [UhstSocket]
  ///
  /// If no [apiClient] is provided or [apiUrl] is not defined in [apiClient]
  /// then [uhst_API_URL] will be used.
  ///
  /// If both [apiClient] and [apiUrl] are defined,
  /// then [apiClient] will be used.
  ///
  /// Use [debug] = true to turn on debug messages
  /// on stream events
  Uhst(
      {String? apiUrl,
      bool? debug,
      UhstApiClient? apiClient,
      RelaySocketProvider? socketProvider}) {
    _debug = debug ?? false;

    var definedApiUrl = apiUrl ?? _uhstApiUrl;
    _apiClient = apiClient ?? ApiClient(apiUrl: definedApiUrl);
    _socketProvider = socketProvider ?? RelaySocketProvider();
  }

  /// Returns [UhstSocket] which able to:
  /// - subscribes to one [UhstHost]
  /// - listen [UhstHost] messages
  /// - send messages to [UhstHost]
  UhstSocket join({required String hostId}) {
    var clientParams = ClientSocketParams(hostId: hostId);
    return _socketProvider.createUhstSocket(
        apiClient: _apiClient, clientParams: clientParams, debug: _debug);
  }

  /// Returns [UhstHost] which able to:
  /// - listen messages from [UhstSocket]
  /// - broadcast messages to all subscsribed Client [UhstSocket]
  UhstHost host({String? hostId}) {
    var host = UhstHost.create(
        apiClient: _apiClient,
        socketProvider: _socketProvider,
        hostId: hostId,
        debug: _debug);
    return host;
  }
}
