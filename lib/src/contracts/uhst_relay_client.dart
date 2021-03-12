library uhst;

import 'package:universal_html/html.dart';

import '../models/client_configuration.dart';
import '../models/host_configration.dart';
import 'uhst_event_handlers.dart';

abstract class UhstRelayClient {
  Future<HostConfiguration> initHost({String? hostId});
  Future<ClientConfiguration> initClient({required String hostId});
  Future<dynamic> sendMessage(
      {required String token, required dynamic message, String? sendUrl});
  EventSource subscribeToMessages(
      {required String token,
      required MessageHandler handler,
      String? receiveUrl});
}
