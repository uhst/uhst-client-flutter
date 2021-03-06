library uhst;

import 'dart:typed_data';

import 'package:universal_html/html.dart';

import 'uhst_event_handlers.dart';

abstract class UhstHostSocket {
  void onReady({required HostReadyHandler handler});
  void onConnection({required HostConnectionHandler handler});
  void onError({required ErrorHandler handler});
  void onDiagnostic({required DiagnosticHandler handler});

  void onceReady({required HostReadyHandler handler});
  void onceConnection({required HostConnectionHandler handler});
  void onceError({required ErrorHandler handler});
  void onceDiagnostic({required DiagnosticHandler handler});

  void offReady({required HostReadyHandler handler});
  void offConnection({required HostConnectionHandler handler});
  void offError({required ErrorHandler handler});
  void offDiagnostic({required DiagnosticHandler handler});

  void disconnect();

  void broadcastString({required String message});
  void broadcastBlob({required Blob blob});

  /// ByteBufer == ArrayBuffer
  /// see https://github.com/dart-lang/sdk/issues/12688
  void broadcastByteBufer({required ByteBuffer byteBuffer});

  /// same as sendByteBufer as ByteBufer == ArrayBuffer
  ///
  /// FIXME: does it needs to exists?
  /// see https://github.com/dart-lang/sdk/issues/12688
  @Deprecated("Use broadcastByteBufer instead")
  void broadcastArrayBuffer({required ByteBuffer arrayBuffer});

  /// TypedData == ArrayBufferView
  ///
  /// see https://api.dart.dev/stable/2.10.4/dart-html/PushMessageData/arrayBuffer.html
  void broadcastTypedData({required TypedData typedData});

  /// same as sendTypedData as TypedData == ArrayBufferView
  ///
  /// FIXME: does it needs to exists?
  /// see https://api.dart.dev/stable/2.10.4/dart-html/PushMessageData/arrayBuffer.html
  @Deprecated("Use broadcastTypedData instead")
  void broadcastArrayBufferView({required TypedData arrayBufferView});
}
