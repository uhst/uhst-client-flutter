library UHST;

import 'dart:html';
import 'dart:typed_data';

import '../models/message.dart';
import '../uhst_event_handlers.dart';

abstract class UhstSocket {
  void onOpen({required OpenHandler handler});
  void onMessage({required MessageHandler handler});
  void onError({required ErrorHandler handler});
  void onClose({required CloseHandler handler});
  void onDiagnostic({required DiagnosticHandler handler});

  void onceOpen({required OpenHandler handler});
  void onceMessage({required MessageHandler handler});
  void onceError({required ErrorHandler handler});
  void onceClose({required CloseHandler handler});
  void onceDiagnostic({required DiagnosticHandler handler});

  void offOpen({required OpenHandler handler});
  void offMessage({required MessageHandler handler});
  void offError({required ErrorHandler handler});
  void offClose({required CloseHandler handler});
  void offDiagnostic({required DiagnosticHandler handler});

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
