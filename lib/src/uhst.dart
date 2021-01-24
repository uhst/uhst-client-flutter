library uhst;

import 'api_client.dart';
import 'contracts/uhst_api_client.dart';
import 'contracts/uhst_socket.dart';
import 'contracts/uhst_socket_provider.dart';
import 'models/socket_params.dart';
import 'relay_socket_provider.dart';
import 'uhst_host.dart';

class Uhst {
  /// Deafult Fallback URL to a uhst API (server)
  /// if [apiUrl] is not defined
  static final String _uhst_API_URL = "https://demo.uhst.io/";

  /// An API client for communication with the server,
  /// normally used for testing or if implementing
  /// [UhstApiClient | custom protocol].
  late UhstApiClient _apiClient;

  /// Set to true and subscribe to "diagnostic" to
  /// receive events from [UhstSocket].
  late bool _debug;

  /// TODO: describe _socketProvider
  late UhstSocketProvider _socketProvider;

  /// [apiUrl] to a server implementing the uhst protocol.
  ///
  /// If no [apiClient] is provided or [apiUrl] is not defined in [apiClient]
  /// then [uhst_API_URL] will be used.
  ///
  /// If both [apiClient] and [apiUrl] are defined,
  /// then [apiClient] will be used.
  Uhst(
      {String? apiUrl,
      bool? debug,
      UhstApiClient? apiClient,
      RelaySocketProvider? socketProvider}) {
    _debug = debug ?? false;

    var definedApiUrl = apiUrl ?? _uhst_API_URL;
    _apiClient = apiClient ?? ApiClient(apiUrl: definedApiUrl);
    _socketProvider = socketProvider ?? RelaySocketProvider();
  }

  /// TODO: describe join
  Future<UhstSocket> join({required String hostId}) async {
    var clientParams = ClientSocketParams(hostId: hostId);
    return await _socketProvider.createUhstSocket(
        apiClient: _apiClient, clientParams: clientParams, debug: _debug);
  }

  /// TODO: describe host
  Future<UhstHost> host({String? hostId}) async {
    var host = await UhstHost.create(
        apiClient: _apiClient,
        socketProvider: _socketProvider,
        hostId: hostId,
        debug: _debug);
    return host;
  }
}
