import 'dart:html';

import 'package:UHST/src/contracts/uhst_api_client.dart';
import 'package:UHST/src/models/socket_params.dart';

import 'contracts/uhst_socket.dart';
import 'models/message.dart';

class RelaySocket implements UhstSocket {
  RelaySocket(
      {required UhstApiClient apiClient,
      ClientSocketParams? clientParams,
      HostSocketParams? hostParams,
      required bool debug}) {
    // TODO: implement RelaySocket constructor
  }
  @override
  void close() {
    // TODO: implement close
  }

  @override
  void handleMessage({required Message message}) {
    // TODO: implement handleMessage
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
  void sendArrayBuffer({required arrayBuffer}) {
    // TODO: implement sendArrayBuffer
  }

  @override
  void sendArrayBufferView({required arrayBufferView}) {
    // TODO: implement sendArrayBufferView
  }

  @override
  void sendBlob({required Blob blob}) {
    // TODO: implement sendBlob
  }

  @override
  void sendString({required String message}) {
    // TODO: implement sendString
  }
}
