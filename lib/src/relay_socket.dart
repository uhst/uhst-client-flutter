library uhst;

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:uhst/src/contracts/uhst_api_client.dart';
import 'package:uhst/src/contracts/uhst_socket_events.dart';
import 'package:uhst/src/models/socket_params.dart';

import 'contracts/uhst_socket.dart';
import 'models/message.dart';
import 'socket_helper.dart';
import 'socket_subsriptions.dart';

class RelaySocket with SocketSubsriptions implements UhstSocket {
  RelaySocket._create({required UhstApiClient apiClient, required bool debug}) {
    h = SocketHelper(apiClient: apiClient, debug: debug);
  }

  static Future<RelaySocket> create(
      {ClientSocketParams? clientParams,
      HostSocketParams? hostParams,
      required UhstApiClient apiClient,
      required bool debug}) async {
    var socket = RelaySocket._create(apiClient: apiClient, debug: debug);
    if (hostParams is HostSocketParams) {
      // client connected
      socket.h.token = hostParams.token;
      socket.h.sendUrl = hostParams.sendUrl;
      // give consumer a chance to subscribe to open event
      var timer = Timer(Duration(microseconds: 1), () {
        socket.h.emit(message: UhstSocketEventType.open);
      });
      timer.cancel();
    } else if (clientParams is ClientSocketParams) {
      // will connect to host
      await socket._initClient(hostId: clientParams.hostId);
    } else {
      throw ArgumentError("Unsupported Socket Parameters Type");
    }
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

      h.emit(message: UhstSocketEventType.open);
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
    var payload = message?.body?.payload;
    if (h.debug) h.emitDiagnostic(body: "Message received: $payload");

    h.emit(message: payload);
  }

  @override
  void sendByteBufer({required ByteBuffer byteBuffer}) {
    _send(message: byteBuffer);
  }

  @override
  @Deprecated("Use sendByteBufer instead")
  void sendArrayBuffer({required arrayBuffer}) {
    sendByteBufer(byteBuffer: arrayBuffer);
  }

  @override
  void sendTypedData({required TypedData typedData}) {
    _send(message: typedData);
  }

  @override
  @Deprecated("Use sendTypedData instead")
  void sendArrayBufferView({required arrayBufferView}) {
    sendTypedData(typedData: arrayBufferView);
  }

  @override
  void sendBlob({required Blob blob}) {
    _send(message: blob);
  }

  @override
  void sendString({required String message}) {
    _send(message: message);
  }

  void _send({dynamic? message}) {
    var envelope = {"type": "string", "payload": message};
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
