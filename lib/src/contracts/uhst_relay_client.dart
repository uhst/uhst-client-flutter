library uhst;

import 'package:universal_html/html.dart';

import '../models/message.dart';
import '../models/client_configuration.dart';
import '../models/host_configration.dart';

typedef void RelayMessageHandler({required Message message});

abstract class UhstRelayClient {
  Future<HostConfiguration> initHost({String? hostId});
  Future<ClientConfiguration> initClient({required String hostId});
  Future<dynamic> sendMessage(
      {required String token, required dynamic message, String? sendUrl});
  Future<EventSource> subscribeToMessages(
      {required String token,
      required RelayMessageHandler handler,
      String? receiveUrl});
}
