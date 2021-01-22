library UHST;

import 'package:UHST/src/uhst_host_event.dart';

import 'contracts/uhst_api_client.dart';
import 'contracts/uhst_host_socket.dart';
import 'contracts/uhst_socket.dart';
import 'contracts/uhst_socket_provider.dart';
import 'models/host_configration.dart';
import 'models/host_message.dart';

// FIXME:
class UhstHost implements UhstHostSocket {
  // TODO: replace to socket
  final Stream<HostEventType> _ee = Stream<HostEventType>.empty();
  final Map<String, UhstSocket> _clients = <String, UhstSocket>{};

  /// Initilizing during init method
  late final HostConfiguration _config;

  /// Initilizing during init method
  late final MessageStream _apiMessageStream;
  final UhstApiClient _apiClient;
  final UhstSocketProvider _socketProvider;
  final bool _debug;

  /// Private factory.
  /// Call it only from static create factory function
  UhstHost._create(
      {required apiClient, required socketProvider, required debug})
      : this._apiClient = apiClient,
        this._socketProvider = socketProvider,
        this._debug = debug;

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
      _config = await _apiClient.initHost(hostId: hostId);
      // if (_debug) _ee.emit("diagnostic", "Host configuration received from server.");
      // _apiMessageStream = await _apiClient.subscribeToMessages(
      //     token: _config.hostToken,
      //     handler: _handleMessage,
      //     receiveUrl: _config.receiveUrl);
      // if (_debug)
      //   _ee.emit("diagnostic", "Host subscribed to messages from server.");

      // _ee.emit("ready");
    } catch (error) {
      if (_debug) {
        // _ee.emit("diagnostic", "Host failed subscribing to messages: " + error);
      }
      // ._ee.emit("error", error);
    }
  }

  void _handleMessage({required HostMessage message}) {
    // String clientId = (JwtDecode(message.responseToken) as any).clientId;
    // var hostSocket = _clients[clientId];
    // if (hostSocket == null) {
    //   var hostParams = HostSocketParams(
    //       token: message.responseToken, sendUrl: _config.sendUrl);
    //   var socket = _socketProvider.createUhstSocket(
    //       apiClient: _apiClient, hostParams: hostParams, debug: _debug);
    //   if (_debug) {
    //     _ee.emit("diagnostic",
    //         "Host received client connection from clientId: " + clientId);
    //   }
    //   _ee.emit("connection", socket);
    //   _clients.update(clientId, (value) => value = socket,
    //       ifAbsent: () => socket);
    //   hostSocket = socket;
    // }
    // hostSocket.handleMessage(message: message);
  }

  String get hostId {
    return _config.hostId;
  }

  void disconnect() {
    // _apiMessageStream?.close();
  }
  @override
  void offConnection({required handler}) {
    // TODO: implement offConnection
  }

  @override
  void offDiagnostic({required handler}) {
    // TODO: implement offDiagnostic
  }

  @override
  void offError({required handler}) {
    // TODO: implement offError
  }

  @override
  void offReady({required handler}) {
    // TODO: implement offReady
  }

  @override
  void onConnection({required handler}) {
    // TODO: implement onConnection
  }

  @override
  void onDiagnostic({required handler}) {
    // TODO: implement onDiagnostic
  }

  @override
  void onError({required handler}) {
    // TODO: implement onError
  }

  @override
  void onReady({required handler}) {
    // TODO: implement onReady
  }

  @override
  void onceConnection({required handler}) {
    // TODO: implement onceConnection
  }

  @override
  void onceDiagnostic({required handler}) {
    // TODO: implement onceDiagnostic
  }

  @override
  void onceError({required handler}) {
    // TODO: implement onceError
  }

  @override
  void onceReady({required handler}) {
    // TODO: implement onceReady
  }
}
