library uhst;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:universal_html/html.dart';

import '../contracts/type_definitions.dart';
import '../contracts/uhst_api_client.dart';
import '../contracts/uhst_socket.dart';
import '../contracts/uhst_socket_events.dart';
import '../models/message.dart';
import '../models/socket_params.dart';
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
///   ?..onOpen(handler: ({required String data}) {
///     setState(() {
///       client?.sendString(message: 'Hello host!');
///     });
///   })
///   ..onMessage(handler: ({required Message? message}) {
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
  RelaySocket._create({required UhstApiClient apiClient, required bool debug}) {
    h = SocketHelper(apiClient: apiClient, debug: debug);
  }

  static RelaySocket create(
      {ClientSocketParams? clientParams,
      HostSocketParams? hostParams,
      required UhstApiClient apiClient,
      required bool debug}) {
    var socket = RelaySocket._create(apiClient: apiClient, debug: debug);

    if (hostParams is HostSocketParams) {
      // client connected
      socket.h.token = hostParams.token;
      socket.h.sendUrl = hostParams.sendUrl;
      // give consumer a chance to subscribe to open event
      var timer = Timer(Duration(milliseconds: 1), () {
        socket.h.emit(message: UhstSocketEventType.open, body: 'opened');
      });
      timer.cancel();
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
      var config = await h.apiClient.initClient(hostId: hostId);
      if (h.debug)
        h.emitDiagnostic(body: "Client configuration received from server.");

      h.token = config.clientToken;
      h.sendUrl = config.sendUrl;
      h.apiMessageStream = await h.apiClient.subscribeToMessages(
          token: config.clientToken,
          handler: handleMessage,
          receiveUrl: config.receiveUrl);
      if (h.debug)
        h.emitDiagnostic(body: "Client subscribed to messages from server.");

      h.emit(message: UhstSocketEventType.open, body: 'opened');
    } catch (error) {
      if (h.debug) h.emitDiagnostic(body: "Client failed: $error");

      h.emitError(body: error);
    }
  }

  @override
  void close() {
    h.apiMessageStream?.close();
  }

  @override
  void handleMessage({Message? message}) {
    if (h.debug)
      h.emitDiagnostic(body: "Message received: ${message?.payload}");

    h.emit(message: UhstSocketEventType.message, body: message);
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

  void _send({dynamic? message, required PayloadType payloadType}) {
    var verifiedMessage = Message(
      payload: message,
      type: payloadType,
      isBroadcast: false,
    );
    var envelope = jsonEncode(verifiedMessage.toJson());
    try {
      h.apiClient.sendMessage(
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
