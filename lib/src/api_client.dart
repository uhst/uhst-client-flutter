import 'contracts/uhst_api_client.dart';
import 'models/client_configuration.dart';
import 'models/host_configration.dart';

class ApiClient implements UhstApiClient {
  final String apiUrl;
  ApiClient({required this.apiUrl});

  @override
  Future<ClientConfiguration> initClient({required String hostId}) {
    // TODO: implement initClient
    throw UnimplementedError();
  }

  @override
  Future<HostConfiguration> initHost({required String hostId}) {
    // TODO: implement initHost
    throw UnimplementedError();
  }

  @override
  Future sendMessage(
      {required String token, required message, String? sendUrl}) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }

  @override
  Future<MessageStream> subscribeToMessages(
      {required String token, required handler, String? receiveUrl}) {
    // TODO: implement subscribeToMessages
    throw UnimplementedError();
  }
}
