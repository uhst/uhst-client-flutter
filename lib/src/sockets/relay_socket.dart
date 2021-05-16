library uhst;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:universal_html/html.dart';

import '../contracts/type_definitions.dart';
import '../contracts/uhst_relay_client.dart';
import '../models/relay_stream.dart';
import '../contracts/uhst_socket.dart';
import '../contracts/uhst_socket_events.dart';
import '../models/message.dart';
import '../models/socket_params.dart';
import '../utils/uhst_exceptions.dart';
import 'socket_helper.dart';
import 'socket_subsriptions.dart';

/// [UhstSocket] is similar to the HTML5 WebSocket interface,
/// but instead of a dedicated server, one peer acts as a host for other
/// peers to join.
///
/// Once a client and a host have connected they can
/// exchange messages asynchronously.
///
/// [UhstSocket] used to:
/// - subscribe to one [UhstHost]
/// - listen [UhstHost] messages
/// - send messages to [UhstHost]
///
/// To connect to a host from another browser use the same `hostId`
/// you received after [UhstSocket().onReady()] event:
///
/// ```dart
/// var client = uhst.join("testHost");
///
/// client?.close();
///
/// client
///   ?..onOpen(handler: () {
///     setState(() {
///       client?.sendString(message: 'Hello host!');
///     });
///   })
///   ..onMessage(handler: ({required message}) {
///     setState(() {
///       clientMessages.add('Client received: $message');
///     });
///   })
///   ..onError(handler: ({required Error error}) {
///     if (error is InvalidHostId || error is InvalidClientOrHostId) {
///       setState(() {
///         clientMessages.add('Invalid hostId!');
///       });
///     } else {
///       setState(() {
///         clientMessages.add(error.toString());
///       });
///     }
///   })
///   ..onDiagnostic(handler: ({required String message}) {
///     setState(() {
///       clientMessages.add(message);
///     });
///   });
/// ```
///
/// The UHST client interface is similar to the HTML5 WebSocket interface,
/// but instead of a dedicated server, one peer acts as a host for other
/// peers to join.
///
/// Once a client and a host have connected they can exchange messages
/// asynchronously. Arbitrary number of clients can connect
/// to the same host but clients cannot send messages to each other,
/// they can only communicate with the host.
///
class RelaySocket with SocketSubsriptions implements UhstSocket {
  RelaySocket._create(
      {required UhstRelayClient relayClient, required bool debug}) {
    h = SocketHelper(relayClient: relayClient, debug: debug);
  }

  static RelaySocket create(
      {ClientSocketParams? clientParams,
      HostSocketParams? hostParams,
      required UhstRelayClient relayClient,
      required bool debug}) {
    var socket = RelaySocket._create(relayClient: relayClient, debug: debug);

    if (hostParams is HostSocketParams) {
      // client connected
      socket.h.token = hostParams.token;
      socket.h.sendUrl = hostParams.sendUrl;
      socket.h.emit(message: UhstSocketEventType.open, body: 'opened');
    } else if (clientParams is ClientSocketParams) {
      // will connect to host
      socket._initClient(hostId: clientParams.hostId);
    } else {
      throw ArgumentError("Unsupported Socket Parameters Type");
    }
    if (debug)
      socket.h.emitDiagnostic(body: {
        'create relay host': hostParams is HostSocketParams,
        'create relay client': clientParams is ClientSocketParams
      });
    return socket;
  }

  Future<void> _initClient({required String hostId}) async {
    try {
      var config = await h.relayClient.initClient(hostId: hostId);
      if (h.debug)
        h.emitDiagnostic(body: "Client configuration received from server.");

      h.token = config.clientToken;
      h.sendUrl = config.sendUrl;
      h.relayClient.subscribeToMessages(
          token: config.clientToken,
          onReady: _handleReady,
          onError: _handleError,
          onMessage: handleMessage,
          receiveUrl: config.receiveUrl);
    } catch (error) {
      if (h.debug) h.emitDiagnostic(body: "Client failed: $error");

      h.emitError(body: error);
    }
  }

  @override
  void close() {
    h.relayMessageStream?.close();
  }

  @override
  void handleMessage({required Message message}) {
    String payload = message.payload;

    if (h.debug) h.emitDiagnostic(body: "Message received: $payload");

    h.emit(message: UhstSocketEventType.message, body: payload);
  }

  @override
  void sendByteBufer({required ByteBuffer byteBuffer}) {
    _send(message: byteBuffer, payloadType: PayloadType.byteBuffer);
  }

  @override
  @Deprecated("Use sendByteBufer instead")
  void sendArrayBuffer({required arrayBuffer}) {
    sendByteBufer(byteBuffer: arrayBuffer);
  }

  @override
  void sendTypedData({required TypedData typedData}) {
    _send(message: typedData, payloadType: PayloadType.typedData);
  }

  @override
  @Deprecated("Use sendTypedData instead")
  void sendArrayBufferView({required arrayBufferView}) {
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

  void _handleReady({required RelayStream stream}) {
    h.relayMessageStream = stream;
    if (h.debug)
      h.emitDiagnostic(body: "Client subscribed to messages from server.");

    h.emit(message: UhstSocketEventType.open, body: 'opened');
  }

  void _handleError({required RelayError error}) {}

  void _send({dynamic? message, required PayloadType payloadType}) {
    var verifiedMessage = Message(
      payload: message,
      type: payloadType,
    );
    var envelope = jsonEncode(verifiedMessage.toJson());
    try {
      h.relayClient.sendMessage(
          token: h.verifiedToken, message: envelope, sendUrl: h.sendUrl);
    } catch (e) {
      if (h.debug) h.emitDiagnostic(body: "Failed sending message: $e");
      h.emitError(body: e);
    }

    if (h.debug) {
      h.emitDiagnostic(body: "Sent message $message");
    }
  }
}
