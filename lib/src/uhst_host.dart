library uhst;

import 'package:uhst/src/host_helper.dart';
import 'package:uhst/src/uhst_errors.dart';
import 'package:uhst/src/uhst_host_event.dart';
import 'package:uhst/src/utils/jwt.dart';

import 'contracts/uhst_host_socket.dart';
import 'contracts/uhst_socket.dart';
import 'contracts/uhst_socket_provider.dart';
import 'host_subscriptions.dart';
import 'models/host_configration.dart';
import 'models/message.dart';
import 'models/socket_params.dart';

class UhstHost with HostSubsriptions implements UhstHostSocket {
  final Map<String, UhstSocket> _clients = <String, UhstSocket>{};

  /// Initilizing during init method
  late final HostConfiguration _config;

  /// Initilizing during init method
  final UhstSocketProvider _socketProvider;

  /// Private factory.
  /// Call it only from static create factory function
  UhstHost._create(
      {required apiClient, required socketProvider, required debug})
      : this._socketProvider = socketProvider {
    h = HostHelper(apiClient: apiClient, debug: debug);
  }

  /// Public factory
  static Future<UhstHost> create(
      {required apiClient,
      required socketProvider,
      String? hostId,
      required debug}) async {
    // Call the private constructor
    var uhstHost = UhstHost._create(
        apiClient: apiClient, debug: debug, socketProvider: socketProvider);

    await uhstHost._init(hostId: hostId);

    return uhstHost;
  }

  /// Initialize function must be called from within
  /// static create factory function
  Future<void> _init({String? hostId}) async {
    try {
      _config = await h.apiClient.initHost(hostId: hostId);
      if (h.debug)
        h.emitDiagnostic(body: "Host configuration received from server.");

      h.apiMessageStream = await h.apiClient.subscribeToMessages(
          token: _config.hostToken,
          handler: _handleMessage,
          receiveUrl: _config.receiveUrl);
      if (h.debug)
        h.emitDiagnostic(body: "Host subscribed to messages from server.");

      h.emit(message: HostEventType.ready);
    } catch (error) {
      if (h.debug)
        h.emitDiagnostic(body: "Host failed subscribing to messages: $error");
      h.emitError(body: error);
    }
  }

  void _handleMessage({required Message? message}) async {
    if (message == null) throw ArgumentError.notNull('message cannot be null');
    var token = message.responseToken;

    if (token == null) throw InvalidToken(token);
    String clientId = Jwt.decodeSubject(token: token);
    var hostSocket = _clients[clientId];

    if (hostSocket == null) {
      var hostParams = HostSocketParams(token: token, sendUrl: _config.sendUrl);
      var socket = await _socketProvider.createUhstSocket(
          apiClient: h.apiClient, hostParams: hostParams, debug: h.debug);
      if (h.debug)
        h.emitDiagnostic(
            body: "Host received client connection from clientId: $clientId");
      h.emit(message: HostEventType.connection, body: socket);
      _clients.update(clientId, (value) => value = socket,
          ifAbsent: () => socket);
      hostSocket = socket;
    }
    hostSocket.handleMessage(message: message);
  }

  String get hostId {
    return _config.hostId;
  }

  void disconnect() {
    h.apiMessageStream?.close();
  }
}
