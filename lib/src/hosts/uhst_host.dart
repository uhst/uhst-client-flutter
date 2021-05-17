library uhst;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:universal_html/html.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../contracts/type_definitions.dart';
import '../contracts/uhst_host_event.dart';
import '../contracts/uhst_host_socket.dart';
import '../contracts/uhst_socket.dart';
import '../contracts/uhst_socket_provider.dart';
import '../contracts/uhst_relay_client.dart';
import '../models/relay_stream.dart';
import '../models/host_configration.dart';
import '../models/message.dart';
import '../models/socket_params.dart';
import '../utils/uhst_exceptions.dart';
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
///
/// host?.disconnect();
///
/// host = uhst?.host(hostId: _hostIdController.text);
///
/// host
///       ?..onReady(handler: ({required String hostId}) {
///         setState(() {
///           hostMessages.add('Host Ready! Using $hostId');
///           print('host is ready!');
///           _hostIdController.text = hostId;
///         });
///       })
///       ..onError(handler: ({required dynamic error}) {
///         print('error received! $error');
///         if (error is HostIdAlreadyInUse) {
///           // this is expected if you refresh the page
///           // connection is still alive on the meeting point
///           // just need to wait
///           setState(() {
///             hostMessages
///                 .add('HostId already in use, retrying in 15 seconds...!');
///           });
///         } else {
///           setState(() {
///             hostMessages.add(error.toString());
///           });
///         }
///       })
///       ..onConnection(handler: ({required UhstSocket uhstSocket}) {
///         uhstSocket.onDiagnostic(handler: ({required String message}) {
///           setState(() {
///             hostMessages.add(message);
///           });
///         });
///         uhstSocket.onMessage(handler: ({required message}) {
///           setState(() {
///             hostMessages.add("Host received: ${message.toString()}");
///             host?.broadcastString(message: message);
///           });
///         });
///         uhstSocket.onOpen(handler: () {
///           // uhstSocket.sendString(message: 'Host sent message!');
///         });
///       });
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
      {required relayClient, required socketProvider, required debug})
      : this._socketProvider = socketProvider {
    h = HostHelper(relayClient: relayClient, debug: debug);
  }

  /// Public factory
  ///
  /// [hostId] can be null and will be returned with `onReady` event
  static UhstHost create(
      {required UhstRelayClient relayClient,
      required UhstSocketProvider socketProvider,
      String? hostId,
      required debug}) {
    // Call the private constructor
    var uhstHost = UhstHost._create(
        relayClient: relayClient, debug: debug, socketProvider: socketProvider);
    uhstHost._init(hostId: hostId);
    return uhstHost;
  }

  /// Initialize function must be called from within
  /// static create factory function
  Future<void> _init({String? hostId}) async {
    try {
      _config = await h.relayClient.initHost(hostId: hostId);
      if (h.debug)
        h.emitDiagnostic(body: "Host configuration received from server.");

      h.relayClient.subscribeToMessages(
          token: _config.hostToken,
          onReady: _handleReady,
          onError: _handleError,
          onMessage: _handleMessage,
          receiveUrl: _config.receiveUrl);
      h.token = _config.hostToken;
      h.sendUrl = _config.sendUrl;
    } catch (error) {
      if (h.debug)
        h.emitDiagnostic(body: "Host failed subscribing to messages: $error");
      h.emitError(body: error);
    }
  }

  void _handleReady({required RelayStream stream}) {
    h.relayMessageStream = stream;
    if (h.debug)
      h.emitDiagnostic(body: "Host subscribed to messages from server.");
    h.emit(message: HostEventType.ready, body: _config.hostId);
  }

  void _handleError({required RelayError error}) {
    if (h.debug)
      h.emitDiagnostic(body: "Host received error from relay: $error");
    h.emitError(body: error);
  }

  void _handleMessage({required Message message}) async {
    var token = message.responseToken;

    if (token == null || token.isEmpty) throw InvalidToken(token);
    try {
      Map<String, dynamic> tokenPayload = JwtDecoder.decode(token);
      String? clientId = tokenPayload['clientId'];
      if (clientId == null) {
        throw InvalidToken(token);
      }
      var hostSocket = _clients[clientId];

      if (hostSocket == null) {
        var hostParams =
            HostSocketParams(token: token, sendUrl: _config.sendUrl);
        var socket = _socketProvider.createUhstSocket(
            relayClient: h.relayClient, hostParams: hostParams, debug: h.debug);
        if (h.debug)
          h.emitDiagnostic(
              body: "Host received client connection from clientId: $clientId");
        h.emit(message: HostEventType.connection, body: socket);
        _clients.update(clientId, (value) => value = socket,
            ifAbsent: () => socket);
        hostSocket = socket;
        // give the connection handler a chance to subscribe
        Timer.run(() => socket.handleMessage(message: message));
      } else {
        hostSocket.handleMessage(message: message);
      }
    } catch (error) {
      throw InvalidToken(token);
    }
  }

  String get hostId {
    return _config.hostId;
  }

  void disconnect() {
    h.relayMessageStream?.close();
  }

  @override
  void broadcastBlob({required Blob blob}) {
    _send(message: blob, payloadType: PayloadType.blob);
  }

  @override
  @Deprecated("Use sendByteBufer instead")
  void broadcastArrayBuffer({required ByteBuffer arrayBuffer}) {
    broadcastByteBufer(byteBuffer: arrayBuffer);
  }

  @override
  void broadcastByteBufer({required ByteBuffer byteBuffer}) {
    _send(message: byteBuffer, payloadType: PayloadType.byteBuffer);
  }

  @override
  @Deprecated("Use sendTypedData instead")
  void broadcastArrayBufferView({required TypedData arrayBufferView}) {
    broadcastTypedData(typedData: arrayBufferView);
  }

  @override
  void broadcastTypedData({required TypedData typedData}) {
    _send(message: typedData, payloadType: PayloadType.typedData);
  }

  @override
  void broadcastString({required String message}) {
    _send(message: message, payloadType: PayloadType.string);
  }

  void _send({dynamic message, required PayloadType payloadType}) async {
    var verifiedMessage = Message(
      payload: message,
      type: payloadType,
    );
    var envelope = jsonEncode(verifiedMessage.toJson());
    try {
      await h.relayClient.sendMessage(
          token: h.verifiedToken, message: envelope, sendUrl: h.sendUrl);
    } catch (e) {
      if (h.debug) h.emitDiagnostic(body: "Failed sending message: $e");
      h.emitError(body: e);
    }
    if (h.debug) h.emitDiagnostic(body: "Sent message $message");
  }
}
