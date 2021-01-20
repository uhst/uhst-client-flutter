library UHST;

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:UHST/src/contracts/uhst_api_client.dart';
import 'package:UHST/src/contracts/uhst_socket_events.dart';
import 'package:UHST/src/models/socket_params.dart';

import 'contracts/uhst_socket.dart';
import 'models/message.dart';
import 'socket_helper.dart';
import 'socket_subsriptions.dart';

class RelaySocket with SocketSubsriptions implements UhstSocket {
  late final SocketHelper _h;

  RelaySocket(
      {required UhstApiClient apiClient,
      ClientSocketParams? clientParams,
      HostSocketParams? hostParams,
      required bool debug}) {
    _h = SocketHelper(apiClient: apiClient, debug: debug);
    if (hostParams is HostSocketParams) {
      // client connected
      _h.token = hostParams.token;
      _h.sendUrl = hostParams.sendUrl;
      // give consumer a chance to subscribe to open event
      var timer = Timer(Duration(microseconds: 1), () {
        _h.emit(message: UhstSocketEventType.open);
      });
      timer.cancel();
    } else if (clientParams is ClientSocketParams) {
      // will connect to host
      // TODO: replace to factory
      _initClient(hostId: clientParams.hostId);
    } else {
      throw ArgumentError("Unsupported Socket Parameters Type");
    }
  }

  Future<void> _initClient({required String hostId}) async {
    try {
      var config = await _h.apiClient.initClient(hostId: hostId);
      if (_h.debug)
        _h.emitDiagnostic(body: "Client configuration received from server.");

      _h.token = config.clientToken;
      _h.sendUrl = config.sendUrl;
      _h.apiMessageStream = await _h.apiClient.subscribeToMessages(
          token: config.clientToken,
          // FIXME: fix types
          handler: handleMessage,
          receiveUrl: config.receiveUrl);
      if (_h.debug)
        _h.emitDiagnostic(body: "Client subscribed to messages from server.");

      _h.emit(message: UhstSocketEventType.open);
    } catch (error) {
      if (_h.debug) _h.emitDiagnostic(body: "Client failed: $error");

      _h.emitError(body: error);
    }
  }

  @override
  void close() {
    _h.apiMessageStream?.close();
  }

  @override
  void handleMessage({required Message message}) {
    var payload = message.body.payload;
    if (_h.debug) _h.emitDiagnostic(body: "Message received: $payload");

    _h.emit(message: payload);
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
      _h.apiClient.sendMessage(
          token: _h.verifiedToken, message: envelope, sendUrl: _h.sendUrl);
    } catch (e) {
      if (_h.debug) _h.emitDiagnostic(body: "Failed sending message: $e");
      _h.emitError(body: e);
    }

    if (_h.debug) {
      _h.emitDiagnostic(body: "Sent message $message");
    }
  }
}
