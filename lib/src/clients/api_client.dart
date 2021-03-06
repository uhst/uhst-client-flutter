import '../contracts/uhst_relay_client.dart';
import '../models/api_response.dart';
import '../models/host_configration.dart';
import '../models/client_configuration.dart';
import './network_client.dart';
import './relay_client.dart';

class _Consts {
  static const apiUrl = 'https://api.uhst.io/v1/get-relay';
}

/// [ApiClient] Wraps [RelayClient] and is responsible for getting a
/// relayUrl from the UHST public relays directory.
class ApiClient implements UhstRelayClient {
  NetworkClient networkClient;
  late RelayClient relayClient;

  ApiClient() : networkClient = new NetworkClient();

  @override
  Future<ClientConfiguration> initClient({required String hostId}) async {
    var relayUrl = await this.getRelayUrl(hostId: hostId);
    this.relayClient = RelayClient(relayUrl: relayUrl);
    return this.relayClient.initClient(hostId: hostId);
  }

  @override
  Future<HostConfiguration> initHost({String? hostId}) async {
    var relayUrl = await this.getRelayUrl(hostId: hostId);
    this.relayClient = RelayClient(relayUrl: relayUrl);
    return this.relayClient.initHost(hostId: hostId);
  }

  @override
  Future sendMessage(
      {required String token, required message, String? sendUrl}) {
    return this
        .relayClient
        .sendMessage(token: token, message: message, sendUrl: sendUrl);
  }

  @override
  subscribeToMessages(
      {required String token,
      required RelayReadyHandler onReady,
      required RelayErrorHandler onError,
      required RelayMessageHandler onMessage,
      String? receiveUrl}) {
    return this.relayClient.subscribeToMessages(
        token: token,
        onReady: onReady,
        onError: onError,
        onMessage: onMessage,
        receiveUrl: receiveUrl);
  }

  Future<String> getRelayUrl({String? hostId}) async {
    var uri = Uri.parse(_Consts.apiUrl);
    if (hostId != null) {
      var qParams = Map<String, String>();
      qParams['hostId'] = hostId;
      uri = uri.replace(queryParameters: qParams);
    }

    var apiResponse =
        await this.networkClient.post(uri: uri, fromJson: ApiResponse.fromJson);
    return apiResponse.url;
  }
}
