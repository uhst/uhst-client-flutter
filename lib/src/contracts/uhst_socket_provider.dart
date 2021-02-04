library uhst;

import '../models/socket_params.dart';
import 'uhst_api_client.dart';
import 'uhst_socket.dart';

abstract class UhstSocketProvider {
  /// [clientParams] or [hostParams] must be defined
  UhstSocket createUhstSocket(
      {required UhstApiClient apiClient,
      ClientSocketParams? clientParams,
      HostSocketParams? hostParams,
      required bool debug});
}
