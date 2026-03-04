import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:universal_html/html.dart';

import '../contracts/contracts.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'socket_helper.dart';
import 'socket_subsriptions_mixin.dart';

/// [RelaySocket] is similar to the HTML5 WebSocket interface,
/// but instead of a dedicated server, one peer acts as a host for other
/// peers to join.
///
/// Once a client and a host have connected they can
/// exchange messages asynchronously.
///
/// [RelaySocket] is used to:
/// - subscribe to one [UhstHost]
/// - listen for [UhstHost] messages
/// - send messages to [UhstHost]
class RelaySocket with SocketSubsriptionsMixin implements UhstSocket {
  RelaySocket._create({
    required UhstRelayClient relayClient,
    required bool debug,
  }) {
    h = SocketHelper(relayClient: relayClient, debug: debug);
  }

  /// Creates a [RelaySocket].
  factory RelaySocket.create({
    required UhstRelayClient relayClient,
    required bool debug,
    ClientSocketParams? clientParams,
    HostSocketParams? hostParams,
  }) {
    final socket = RelaySocket._create(
      relayClient: relayClient,
      debug: debug,
    );

    if (hostParams is HostSocketParams) {
      // client connected
      socket.h.token = hostParams.token;
      socket.h.remoteId = hostParams.clientId;
      socket.h.sendUrl = hostParams.sendUrl;
      // give consumer a chance to subscribe to open event
      Timer.run(
        () => socket.h.emit(
          message: UhstSocketEventType.open,
          body: 'opened',
        ),
      );
    } else if (clientParams is ClientSocketParams) {
      // will connect to host
      socket._initClient(hostId: clientParams.hostId);
    } else {
      throw ArgumentError.value(
        hostParams,
        'hostParams',
        'unsupported',
      );
    }
    if (debug) {
      socket.h.emitDiagnostic(body: {
        'create relay host': hostParams is HostSocketParams,
        'create relay client': clientParams is ClientSocketParams,
      });
    }
    return socket;
  }

  Future<void> _initClient({required String hostId}) async {
    try {
      final config = await h.relayClient.initClient(hostId: hostId);
      if (h.debug) {
        h.emitDiagnostic(
          body: 'Client configuration received from server.',
        );
      }

      h
        ..remoteId = hostId
        ..token = config.clientToken
        ..sendUrl = config.sendUrl
        ..relayClient.subscribeToMessages(
          token: config.clientToken,
          onReady: _onClientReady,
          onException: _onClientException,
          onMessage: onClientMessage,
          onRelayEvent: _onClientRelayEvent,
          receiveUrl: config.receiveUrl,
        );
    } on Exception catch (exception) {
      if (h.debug) {
        h.emitDiagnostic(body: 'Client failed: $exception');
      }
      h.emitException(body: exception);
    }
  }

  @override
  String? get remoteId => h.remoteId;

  @override
  void close() {
    h.emit(
      message: UhstSocketEventType.close,
      body: remoteId,
    );
    h.relayMessageStream?.close();
  }

  @override
  void dispose() {
    close();
    h.eventStreamController.close();
  }

  @override
  void sendByteBufer({required ByteBuffer byteBuffer}) {
    _send(
      message: byteBuffer,
      payloadType: PayloadType.byteBuffer,
    );
  }

  @override
  @Deprecated('Use sendByteBufer instead')
  void sendArrayBuffer({required ByteBuffer arrayBuffer}) {
    sendByteBufer(byteBuffer: arrayBuffer);
  }

  @override
  void sendTypedData({required TypedData typedData}) {
    _send(
      message: typedData,
      payloadType: PayloadType.typedData,
    );
  }

  @override
  @Deprecated('Use sendTypedData instead')
  void sendArrayBufferView({
    required TypedData arrayBufferView,
  }) {
    sendTypedData(typedData: arrayBufferView);
  }

  @override
  void sendBlob({required Blob blob}) {
    _send(message: blob, payloadType: PayloadType.blob);
  }

  @override
  void sendString({required String message}) {
    _send(message: message, payloadType: PayloadType.string);
  }

  void _onClientReady({required RelayStream stream}) {
    h.relayMessageStream = stream;
    if (h.debug) {
      h.emitDiagnostic(
        body: 'Client subscribed to messages from server.',
      );
    }

    h.emit(
      message: UhstSocketEventType.open,
      body: 'opened',
    );
  }

  void _onClientException({
    required RelayException exception,
  }) {
    if (h.debug) {
      h.emitDiagnostic(
        body: 'Client connection to relay dropped with exception: '
            '$exception',
      );
    }
    close();
  }

  void _onClientRelayEvent({required RelayEvent event}) {
    switch (event.eventType) {
      case RelayEventType.hostClosed:
        if (h.debug) {
          h.emitDiagnostic(
            body: 'Host disconnected from relay.',
          );
        }
        h.emitException(
          body: HostDisconnected(
            'Host disconnected from relay.',
          ),
        );
        close();
      case RelayEventType.clientClosed:
        break;
    }
  }

  @override
  void onClientMessage({required Message message}) {
    final String payload = message.payload;

    if (h.debug) {
      h.emitDiagnostic(body: 'Message received: $payload');
    }

    h.emit(
      message: UhstSocketEventType.message,
      body: payload,
    );
  }

  void _send({
    required PayloadType payloadType,
    dynamic message,
  }) {
    final verifiedMessage = Message(
      payload: message,
      type: payloadType,
    );
    final envelope = jsonEncode(verifiedMessage.toJson());
    try {
      h.relayClient.sendMessage(
        token: h.verifiedToken,
        message: envelope,
        sendUrl: h.sendUrl,
      );
    } on Exception catch (e) {
      if (h.debug) {
        h.emitDiagnostic(body: 'Failed sending message: $e');
      }
      h.emitException(body: e);
    }

    if (h.debug) {
      h.emitDiagnostic(body: 'Sent message $message');
    }
  }
}
