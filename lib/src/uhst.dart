library UHST;

import 'api_client.dart';
import 'contracts/uhst_api_client.dart';
import 'contracts/uhst_socket.dart';
import 'contracts/uhst_socket_provider.dart';
import 'models/socket_params.dart';
import 'relay_socket_provider.dart';

class UHST {
  /// Deafult Fallback URL to a UHST API (server)
  /// if [apiUrl] is not defined
  static final String _UHST_API_URL = "https://demo.uhst.io/";

  /// An API client for communication with the server,
  /// normally used for testing or if implementing
  /// [UhstApiClient | custom protocol].
  late UhstApiClient _apiClient;

  /// Set to true and subscribe to "diagnostic" to
  /// receive events from [UhstSocket].
  late bool _debug;

  /// TODO: describe _socketProvider
  late UhstSocketProvider _socketProvider;

  /// [apiUrl] to a server implementing the UHST protocol.
  ///
  /// If no [apiClient] is provided or [apiUrl] is not defined in [apiClient]
  /// then [UHST_API_URL] will be used.
  ///
  /// If both [apiClient] and [apiUrl] are defined,
  /// then [apiClient] will be used.
  UHST(
      {String? apiUrl,
      bool? debug,
      UhstApiClient? apiClient,
      RelaySocketProvider? socketProvider}) {
    _debug = debug ?? false;

    var definedApiUrl = apiUrl ?? _UHST_API_URL;
    _apiClient = apiClient ?? ApiClient(apiUrl: definedApiUrl);
    _socketProvider = socketProvider ?? RelaySocketProvider();
  }

  /// TODO: describe join
  UhstSocket join({required String hostId}) {
    var clientParams = ClientSocketParams(hostId: hostId);
    return _socketProvider.createUhstSocket(
        apiClient: _apiClient, clientParams: clientParams, debug: _debug);
  }

  /// TODO: describe host
  /// TODO: implement [UhstHost]
  UhstHost host({required String hostId}) {
    return UhstHost(
        apiClient: _apiClient,
        socketProvider: _socketProvider,
        hostId: hostId,
        debug: _debug);
  }
}
