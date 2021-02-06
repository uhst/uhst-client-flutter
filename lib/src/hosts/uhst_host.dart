library uhst;

import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import '../contracts/uhst_host_event.dart';
import '../contracts/uhst_host_socket.dart';
import '../contracts/uhst_socket.dart';
import '../contracts/uhst_socket_provider.dart';
import '../models/host_configration.dart';
import '../models/message.dart';
import '../models/socket_params.dart';
import '../utils/jwt.dart';
import '../utils/uhst_errors.dart';
import 'host_helper.dart';
import 'host_subscriptions.dart';

/// [UhstHost] in UHST is a peer which every other peer ([UhstSocket])
/// connects to. This concept is similar to listen-server in multiplayer games.
///
/// [UhstHost] used to:
/// - listen messages from [UhstSocket]
/// - broadcast messages to all subscsribed Client [UhstSocket]
///
/// The simplest way to create a new host is:
///
/// ```dart
/// var host = uhst.host("testHost");
/// host
///   ..onReady(handler: () {
///     setState(() {
///         hostMessages.add('Host Ready!');
///       });
///       print('host is ready!');
///     })
///   ..onError(handler: ({required Error error}) {
///       print('error received! $error');
///       if (error is HostIdAlreadyInUse) {
///         // this is expected if you refresh the page
///         // connection is still alive on the meeting point
///         // just need to wait
///         setState(() {
///           hostMessages
///               .add('HostId already in use, retrying in 15 seconds...!');
///         });
///       } else {
///         setState(() {
///           hostMessages.add(error.toString());
///         });
///       }
///     })
///   ..onConnection(handler: ({required UhstSocket uhstSocket}) {
///     uhstSocket.onDiagnostic(handler: ({required String message}) {
///       setState(() {
///         hostMessages.add(message);
///       });
///     });
///     uhstSocket.onMessage(handler: ({required Message? message}) {
///       setState(() {
///         hostMessages
///             .add("Host received: ${message?.body} ${message?.type}");
///         var payload = message?.payload;
///         if (payload != null) host.broadcastString(message: payload);
///       });
///     });
///     uhstSocket.onOpen(handler: ({required String? data}) {
///       uhstSocket.sendString(message: 'Host sent message!');
///     });
///   });
/// }
/// ```
///
/// Note that your requested host id may not be accepted
/// by the signalling server, you should always use the `hostId`
/// you get after receiving a [UhstHost().onReady()] event
/// when connecting to the host.
///
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
  static UhstHost create(
      {required apiClient,
      required socketProvider,
      String? hostId,
      required debug}) {
    // Call the private constructor
    var uhstHost = UhstHost._create(
        apiClient: apiClient, debug: debug, socketProvider: socketProvider);
    uhstHost._init(hostId: hostId);

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
      h.emit(message: HostEventType.ready, body: 'is ready');
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

  @override
  void broadcastBlob({required Blob blob}) {
    _send(message: blob);
  }

  @override
  @Deprecated("Use sendByteBufer instead")
  void broadcastArrayBuffer({required ByteBuffer arrayBuffer}) {
    _send(message: arrayBuffer);
  }

  @override
  void broadcastByteBufer({required ByteBuffer byteBuffer}) {
    _send(message: byteBuffer);
  }

  @override
  @Deprecated("Use sendTypedData instead")
  void broadcastArrayBufferView({required TypedData arrayBufferView}) {
    _send(message: arrayBufferView);
  }

  @override
  void broadcastTypedData({required TypedData typedData}) {
    _send(message: typedData);
  }

  @override
  void broadcastString({required String message}) {
    _send(message: message);
  }

  void _send({dynamic? message}) {
    var envelope = jsonEncode({"type": "string", "payload": message});
    try {
      h.apiClient.sendMessage(
          token: h.verifiedToken, message: envelope, sendUrl: h.sendUrl);
    } catch (e) {
      if (h.debug) h.emitDiagnostic(body: "Failed sending message: $e");
      h.emitError(body: e);
    }

    if (h.debug) h.emitDiagnostic(body: "Sent message $message");
  }
}