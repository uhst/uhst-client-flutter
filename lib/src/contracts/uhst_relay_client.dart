library uhst;

import '../models/message.dart';
import '../models/client_configuration.dart';
import '../models/host_configration.dart';
import '../models/relay_stream.dart';
import '../utils/uhst_exceptions.dart';

typedef void RelayReadyHandler({required RelayStream stream});
typedef void RelayMessageHandler({required Message message});
typedef void RelayErrorHandler({required RelayError error});

abstract class UhstRelayClient {
  Future<HostConfiguration> initHost({String? hostId});
  Future<ClientConfiguration> initClient({required String hostId});
  Future<dynamic> sendMessage(
      {required String token, required dynamic message, String? sendUrl});
  subscribeToMessages(
      {required String token,
      required RelayReadyHandler onReady,
      required RelayErrorHandler onError,
      required RelayMessageHandler onMessage,
      String? receiveUrl});
}
