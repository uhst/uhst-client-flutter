import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:universal_html/html.dart';

import '../contracts/contracts.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'host_helper.dart';
import 'host_subscriptions_mixin.dart';

/// [UhstHost] in UHST is a peer which every other peer ([UhstSocket])
/// connects to. This concept is similar to listen-server in multiplayer
/// games.
///
/// [UhstHost] is used to:
/// - listen for messages from [UhstSocket]
/// - broadcast messages to all subscribed Client [UhstSocket]
///
/// Remember to call `.dispose()` to cancel all subscriptions and
/// disconnect host socket from server, client from host.
class UhstHost with HostSubsriptionsMixin implements UhstHostSocket {
  /// Private factory.
  /// Call it only from static create factory function.
  UhstHost._create({
    required relayClient,
    required socketProvider,
    required debug,
  }) : _socketProvider = socketProvider {
    h = HostHelper(relayClient: relayClient, debug: debug);
  }

  /// Public factory.
  ///
  /// [hostId] can be null and will be returned with `onReady`
  /// event.
  factory UhstHost.create({
    required UhstRelayClient relayClient,
    required UhstSocketProvider socketProvider,
    required bool debug,
    String? hostId,
  }) {
    // Call the private constructor
    final uhstHost = UhstHost._create(
      relayClient: relayClient,
      debug: debug,
      socketProvider: socketProvider,
    ).._init(hostId: hostId);
    return uhstHost;
  }

  final Map<String, UhstSocket> _clients = <String, UhstSocket>{};

  /// Initialized during init method.
  late final HostConfiguration _config;

  /// Initialized during init method.
  final UhstSocketProvider _socketProvider;

  /// Initialize function must be called from within
  /// static create factory function.
  Future<void> _init({String? hostId}) async {
    try {
      _config = await h.relayClient.initHost(hostId: hostId);
      if (h.debug) {
        h.emitDiagnostic(
          body: 'Host configuration received from server.',
        );
      }

      h
        ..relayClient.subscribeToMessages(
          token: _config.hostToken,
          onReady: _handleReady,
          onException: _handleException,
          onMessage: _handleMessage,
          receiveUrl: _config.receiveUrl,
          onRelayEvent: _handleRelayEvent,
        )
        ..token = _config.hostToken
        ..sendUrl = _config.sendUrl;
    } on Exception catch (exception) {
      if (h.debug) {
        h.emitDiagnostic(
          body: 'Host failed subscribing to messages: $exception',
        );
      }
      h.emitException(body: exception);
    }
  }

  void _handleRelayEvent({required RelayEvent event}) {
    switch (event.eventType) {
      case RelayEventType.clientClosed:
        final clientId = event.payload;
        _clients[clientId]?.close();
        _clients.remove(clientId);
      case RelayEventType.hostClosed:
        break;
    }
  }

  void _handleReady({required RelayStream stream}) {
    h.relayMessageStream = stream;
    if (h.debug) {
      h.emitDiagnostic(
        body: 'Host subscribed to messages from server.',
      );
    }
    h.emit(
      message: HostEventType.ready,
      body: _config.hostId,
    );
  }

  void _handleException({
    required RelayException exception,
  }) {
    if (h.debug) {
      h.emitDiagnostic(
        body: 'Host received exception from relay: $exception',
      );
    }
    h.emitException(body: exception);
    disconnect();
  }

  Future<void> _handleMessage({
    required Message message,
  }) async {
    final token = message.responseToken ?? '';

    if (token.isEmpty) throw InvalidToken(token);

    final Map<String, dynamic> tokenPayload = JwtDecoder.decode(token);
    final String? clientId = tokenPayload['clientId'];
    if (clientId == null) {
      throw InvalidToken(token);
    }
    final hostSocket = _clients[clientId];

    if (hostSocket == null) {
      final hostParams = HostSocketParams(
        token: token,
        clientId: clientId,
        sendUrl: _config.sendUrl,
      );
      final socket = _socketProvider.createUhstSocket(
        relayClient: h.relayClient,
        hostParams: hostParams,
        debug: h.debug,
      );
      if (h.debug) {
        h.emitDiagnostic(
          body: 'Host received client connection from '
              'clientId: $clientId',
        );
      }
      h.emit(
        message: HostEventType.connection,
        body: socket,
      );
      _clients[clientId] = socket;
      // give the connection handler a chance to subscribe
      Timer.run(
        () => socket.onClientMessage(message: message),
      );
    } else {
      hostSocket.onClientMessage(message: message);
    }
  }

  /// Static id that can identify a host.
  String get hostId => _config.hostId;

  @override
  void disconnect() {
    h.emit(message: HostEventType.close, body: hostId);
    h.relayMessageStream?.close();
    _clients.clear();
  }

  @override
  void dispose() {
    disconnect();
    h.eventStreamController.close();
  }

  @override
  void broadcastBlob({required Blob blob}) {
    _send(message: blob, payloadType: PayloadType.blob);
  }

  @override
  @Deprecated('Use broadcastByteBufer instead')
  void broadcastArrayBuffer({
    required ByteBuffer arrayBuffer,
  }) {
    broadcastByteBufer(byteBuffer: arrayBuffer);
  }

  @override
  void broadcastByteBufer({required ByteBuffer byteBuffer}) {
    _send(
      message: byteBuffer,
      payloadType: PayloadType.byteBuffer,
    );
  }

  @override
  @Deprecated('Use broadcastTypedData instead')
  void broadcastArrayBufferView({
    required TypedData arrayBufferView,
  }) {
    broadcastTypedData(typedData: arrayBufferView);
  }

  @override
  void broadcastTypedData({required TypedData typedData}) {
    _send(
      message: typedData,
      payloadType: PayloadType.typedData,
    );
  }

  @override
  void broadcastString({required String message}) {
    _send(message: message, payloadType: PayloadType.string);
  }

  Future<void> _send({
    required PayloadType payloadType,
    dynamic message,
  }) async {
    final verifiedMessage = Message(
      payload: message,
      type: payloadType,
    );
    final envelope = jsonEncode(verifiedMessage.toJson());
    try {
      await h.relayClient.sendMessage(
        token: h.verifiedToken,
        message: envelope,
        sendUrl: h.sendUrl,
      );
      if (h.debug) {
        h.emitDiagnostic(body: 'Sent message $message');
      }
    } on Exception catch (e) {
      if (h.debug) {
        h.emitDiagnostic(
          body: 'Failed sending message: $e',
        );
      }
      h.emitException(body: e);
    }
  }
}
