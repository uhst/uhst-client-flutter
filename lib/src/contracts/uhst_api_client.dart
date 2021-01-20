library UHST;

import '../models/client_configuration.dart';
import '../models/host_configration.dart';
import '../uhst_event_handlers.dart';

abstract class MessageStream {
  void close();
}

abstract class UhstApiClient {
  Future<HostConfiguration> initHost({required String hostId});
  Future<ClientConfiguration> initClient({required String hostId});
  Future<dynamic> sendMessage(
      {required String token, required dynamic message, String? sendUrl});
  Future<MessageStream> subscribeToMessages(
      {required String token,
      required MessageHandler handler,
      String? receiveUrl});
}
