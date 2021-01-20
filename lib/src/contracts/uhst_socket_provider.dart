library UHST;

import '../models/socket_params.dart';
import 'uhst_api_client.dart';
import 'uhst_socket.dart';

abstract class UhstSocketProvider {
  /// [clientParams] or [hostParams] must be defined
  Future<UhstSocket> createUhstSocket(
      {required UhstApiClient apiClient,
      ClientSocketParams? clientParams,
      HostSocketParams? hostParams,
      required bool debug});
}
