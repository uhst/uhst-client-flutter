import 'dart:typed_data';

import 'package:universal_html/html.dart';

import '../models/models.dart';
import 'uhst_event_handlers.dart';

/// Client socket interface for UHST connections.
abstract class UhstSocket {
  /// The remote peer ID.
  String? get remoteId;

  /// Subscribe to open events.
  void onOpen({required OpenHandler handler});

  /// Subscribe to message events.
  void onMessage({required MessageHandler handler});

  /// Subscribe to exception events.
  void onException({required ExceptionHandler handler});

  /// Subscribe to close events.
  void onClose({required CloseHandler handler});

  /// Subscribe to diagnostic events.
  void onDiagnostic({required DiagnosticHandler handler});

  /// Subscribe to open event once.
  void onceOpen({required OpenHandler handler});

  /// Subscribe to message event once.
  void onceMessage({required MessageHandler handler});

  /// Subscribe to exception event once.
  void onceException({required ExceptionHandler handler});

  /// Subscribe to close event once.
  void onceClose({required CloseHandler handler});

  /// Subscribe to diagnostic event once.
  void onceDiagnostic({required DiagnosticHandler handler});

  /// Unsubscribe from open events.
  void offOpen({required OpenHandler handler});

  /// Unsubscribe from message events.
  void offMessage({required MessageHandler handler});

  /// Unsubscribe from exception events.
  void offException({required ExceptionHandler handler});

  /// Unsubscribe from close events.
  void offClose({required CloseHandler handler});

  /// Unsubscribe from diagnostic events.
  void offDiagnostic({required DiagnosticHandler handler});

  /// Send a string message.
  void sendString({required String message});

  /// Send a blob message.
  void sendBlob({required Blob blob});

  /// Send a byte buffer message.
  /// ByteBufer == ArrayBuffer
  /// see https://github.com/dart-lang/sdk/issues/12688
  void sendByteBufer({required ByteBuffer byteBuffer});

  /// Same as sendByteBufer as ByteBufer == ArrayBuffer.
  /// see https://github.com/dart-lang/sdk/issues/12688
  @Deprecated('Use sendByteBufer instead')
  void sendArrayBuffer({required ByteBuffer arrayBuffer});

  /// Send typed data.
  /// TypedData == ArrayBufferView
  void sendTypedData({required TypedData typedData});

  /// Same as sendTypedData as TypedData == ArrayBufferView.
  @Deprecated('Use sendTypedData instead')
  void sendArrayBufferView({required TypedData arrayBufferView});

  /// This method is used to close EventSource.
  /// Before close, [onClose] [onceClose] will be called, if any provided.
  void close();

  /// This method should be called during dispose to cancel all subscriptions.
  ///
  /// This method will start with [close] call.
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   client?.dispose();
  ///   host?.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose();

  /// Handle a message from a client.
  void onClientMessage({required Message message});
}
