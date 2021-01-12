library UHST;

import 'dart:html';

import '../models/message.dart';

typedef void OpenHandler({required String data});
typedef void MessageHandler({required String data});
typedef void ErrorHandler({required Error error});
typedef void CloseHandler();
typedef void DiagnosticHandler({required String message});

abstract class UhstSocket {
  onOpen({required OpenHandler handler});
  onMessage({required MessageHandler handler});
  onError({required ErrorHandler handler});
  onClose({required CloseHandler handler});
  onDiagnostic({required DiagnosticHandler handler});

  onceOpen({required OpenHandler handler});
  onceMessage({required MessageHandler handler});
  onceError({required ErrorHandler handler});
  onceClose({required CloseHandler handler});
  onceDiagnostic({required DiagnosticHandler handler});

  offOpen({required OpenHandler handler});
  offMessage({required MessageHandler handler});
  offError({required ErrorHandler handler});
  offClose({required CloseHandler handler});
  offDiagnostic({required DiagnosticHandler handler});

  void sendString({required String message});
  void sendBlob({required Blob blob});
  void sendArrayBuffer({required ArrayBuffer arrayBuffer});
  void sendArrayBufferView({required ArrayBufferView arrayBufferView});

  void close();

  void handleMessage({required Message message});
}
