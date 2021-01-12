library UHST;

import 'dart:html';
import 'dart:typed_data';

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

  /// ByteBufer == ArrayBuffer
  /// see https://github.com/dart-lang/sdk/issues/12688
  void sendByteBufer({required ByteBuffer byteBuffer});

  /// same as sendByteBufer as ByteBufer == ArrayBuffer
  ///
  /// FIXME: does it needs to exists?
  /// see https://github.com/dart-lang/sdk/issues/12688
  @Deprecated("Use sendByteBufer instead")
  void sendArrayBuffer({required ByteBuffer arrayBuffer});

  /// TypedData == ArrayBufferView
  ///
  /// see https://api.dart.dev/stable/2.10.4/dart-html/PushMessageData/arrayBuffer.html
  void sendTypedData({required TypedData typedData});

  /// same as sendTypedData as TypedData == ArrayBufferView
  ///
  /// FIXME: does it needs to exists?
  /// see https://api.dart.dev/stable/2.10.4/dart-html/PushMessageData/arrayBuffer.html
  @Deprecated("Use sendTypedData instead")
  void sendArrayBufferView({required TypedData arrayBufferView});

  void close();

  void handleMessage({required Message message});
}
