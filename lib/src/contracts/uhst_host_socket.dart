import 'dart:async';
import 'dart:typed_data';

import 'package:universal_html/html.dart';

import 'uhst_event_handlers.dart';
import 'uhst_host_event.dart';

/// Host socket interface for UHST connections.
abstract class UhstHostSocket {
  /// Subscribe to ready events.
  StreamSubscription<Map<HostEventType, dynamic>> onReady(
      {required HostReadyHandler handler});

  /// Subscribe to connection events.
  StreamSubscription<Map<HostEventType, dynamic>> onConnection(
      {required HostConnectionHandler handler});

  /// Subscribe to exception events.
  StreamSubscription<Map<HostEventType, dynamic>> onException(
      {required ExceptionHandler handler});

  /// Subscribe to diagnostic events.
  StreamSubscription<Map<HostEventType, dynamic>> onDiagnostic(
      {required DiagnosticHandler handler});

  /// Subscribe to close events.
  StreamSubscription<Map<HostEventType, dynamic>> onClose(
      {required CloseHandler handler});

  /// Subscribe to ready event once.
  void onceReady({required HostReadyHandler handler});

  /// Subscribe to connection event once.
  void onceConnection({required HostConnectionHandler handler});

  /// Subscribe to exception event once.
  void onceException({required ExceptionHandler handler});

  /// Subscribe to diagnostic event once.
  void onceDiagnostic({required DiagnosticHandler handler});

  /// Subscribe to close event once.
  void onceClose({required CloseHandler handler});

  /// Unsubscribe from ready events.
  void offReady({required HostReadyHandler handler});

  /// Unsubscribe from connection events.
  void offConnection({required HostConnectionHandler handler});

  /// Unsubscribe from exception events.
  void offException({required ExceptionHandler handler});

  /// Unsubscribe from diagnostic events.
  void offDiagnostic({required DiagnosticHandler handler});

  /// Unsubscribe from close events.
  void offClose({required CloseHandler handler});

  /// This method is used to close EventSource.
  /// Before close, [onClose] [onceClose] will be called, if any provided.
  void disconnect();

  /// This method should be called during dispose to cancel all subscriptions.
  ///
  /// This method will start with [disconnect] call.
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

  /// Broadcast a string message to all clients.
  void broadcastString({required String message});

  /// Broadcast a blob to all clients.
  void broadcastBlob({required Blob blob});

  /// Broadcast a byte buffer to all clients.
  /// ByteBufer == ArrayBuffer
  /// see https://github.com/dart-lang/sdk/issues/12688
  void broadcastByteBufer({required ByteBuffer byteBuffer});

  /// Same as broadcastByteBufer.
  /// see https://github.com/dart-lang/sdk/issues/12688
  @Deprecated('Use broadcastByteBufer instead')
  void broadcastArrayBuffer({required ByteBuffer arrayBuffer});

  /// Broadcast typed data to all clients.
  /// TypedData == ArrayBufferView
  void broadcastTypedData({required TypedData typedData});

  /// Same as broadcastTypedData.
  @Deprecated('Use broadcastTypedData instead')
  void broadcastArrayBufferView({required TypedData arrayBufferView});
}
