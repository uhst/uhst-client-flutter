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

class RelaySocket implements UhstSocket {
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
      _initClient(hostId: clientParams.hostId);
    } else {
      throw ArgumentError("Unsupported Socket Parameters Type");
    }
  }
  Future<void> _initClient({required String hostId}) async {
    try {
      var config = await _h.apiClient.initClient(hostId: hostId);
      if (this.debug) {
        this
            ._ee
            .emit("diagnostic", "Client configuration received from server.");
      }
      this.token = config.clientToken;
      this.sendUrl = config.sendUrl;
      this.apiMessageStream = await this.apiClient.subscribeToMessages(
          config.clientToken, this.handleMessage, config.receiveUrl);
      if (this.debug) {
        this
            ._ee
            .emit("diagnostic", "Client subscribed to messages from server.");
      }
      this._ee.emit("open");
    } catch (error) {
      if (this.debug) {
        this._ee.emit("diagnostic", "Client failed: " + JSON.stringify(error));
      }
      this._ee.emit("error", error);
    }
  }

  @override
  void close() {
    _h.apiMessageStream?.close();
  }

  @override
  void handleMessage({required Message message}) {
    // const payload = message.body.payload
    // if (this.debug) { this._ee.emit("diagnostic", "Message received: " + payload); }
    // this._ee.emit("message", payload);
  }

  @override
  offClose({required handler}) {
    // TODO: implement offClose
    throw UnimplementedError();
  }

  @override
  offDiagnostic({required handler}) {
    // TODO: implement offDiagnostic
    throw UnimplementedError();
  }

  @override
  offError({required handler}) {
    // TODO: implement offError
    throw UnimplementedError();
  }

  @override
  offMessage({required handler}) {
    // TODO: implement offMessage
    throw UnimplementedError();
  }

  @override
  offOpen({required handler}) {
    // TODO: implement offOpen
    throw UnimplementedError();
  }

  @override
  onClose({required handler}) {
    // TODO: implement onClose
    throw UnimplementedError();
  }

  @override
  onDiagnostic({required handler}) {
    // TODO: implement onDiagnostic
    throw UnimplementedError();
  }

  @override
  onError({required handler}) {
    // TODO: implement onError
    throw UnimplementedError();
  }

  @override
  onMessage({required handler}) {
    // TODO: implement onMessage
    throw UnimplementedError();
  }

  @override
  onOpen({required handler}) {
    // TODO: implement onOpen
    throw UnimplementedError();
  }

  @override
  onceClose({required handler}) {
    // TODO: implement onceClose
    throw UnimplementedError();
  }

  @override
  onceDiagnostic({required handler}) {
    // TODO: implement onceDiagnostic
    throw UnimplementedError();
  }

  @override
  onceError({required handler}) {
    // TODO: implement onceError
    throw UnimplementedError();
  }

  @override
  onceMessage({required handler}) {
    // TODO: implement onceMessage
    throw UnimplementedError();
  }

  @override
  onceOpen({required handler}) {
    // TODO: implement onceOpen
    throw UnimplementedError();
  }

  @override
  void sendByteBufer({required ByteBuffer byteBuffer}) {
    // TODO: implement sendByteBufer
  }
  @override
  @Deprecated("Use sendByteBufer instead")
  void sendArrayBuffer({required arrayBuffer}) {
    sendByteBufer(byteBuffer: arrayBuffer);
  }

  @override
  void sendTypedData({required TypedData typedData}) {
    // TODO: implement sendTypedData
  }
  @override
  @Deprecated("Use sendTypedData instead")
  void sendArrayBufferView({required arrayBufferView}) {
    sendTypedData(typedData: arrayBufferView);
  }

  @override
  void sendBlob({required Blob blob}) {
    // TODO: implement sendBlob
  }

  @override
  void sendString({required String message}) {
    // TODO: implement sendString
  }
  void _send() {
    // const envelope = {
    //         "type": "string",
    //         "payload": message
    //     }
    //     this.apiClient.sendMessage(this.token, envelope, this.sendUrl).catch((error) => {
    //         if (this.debug) { this._ee.emit("diagnostic", "Failed sending message: " + JSON.stringify(error)); }
    //         this._ee.emit("error", error);
    //     });
    //     if (this.debug) { this._ee.emit("diagnostic", "Sent message " + message); }
  }
}
