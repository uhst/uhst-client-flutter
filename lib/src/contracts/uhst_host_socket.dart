part of uhst_contracts;

abstract class UhstHostSocket {
  StreamSubscription<Map<HostEventType, dynamic>> onReady(
      {required HostReadyHandler handler});
  StreamSubscription<Map<HostEventType, dynamic>> onConnection(
      {required HostConnectionHandler handler});
  StreamSubscription<Map<HostEventType, dynamic>> onException(
      {required ExceptionHandler handler});
  StreamSubscription<Map<HostEventType, dynamic>> onDiagnostic(
      {required DiagnosticHandler handler});
  StreamSubscription<Map<HostEventType, dynamic>> onClose(
      {required CloseHandler handler});

  void onceReady({required HostReadyHandler handler});
  void onceConnection({required HostConnectionHandler handler});
  void onceException({required ExceptionHandler handler});
  void onceDiagnostic({required DiagnosticHandler handler});
  void onceClose({required CloseHandler handler});

  void offReady({required HostReadyHandler handler});
  void offConnection({required HostConnectionHandler handler});
  void offException({required ExceptionHandler handler});
  void offDiagnostic({required DiagnosticHandler handler});
  void offClose({required CloseHandler handler});

  /// This method is using to close EventSource.
  /// Before close will be fired [onClose] [onceClose]
  /// will be called, if any provided
  void disconnect();

  /// This method should be called during dispose method in Flutter widget
  /// or any another cases that require to cancel all subscriptions and
  /// all methods
  ///
  /// This method will started with [disconnect] call
  void dispose();

  void broadcastString({required String message});
  void broadcastBlob({required Blob blob});

  /// ByteBufer == ArrayBuffer
  /// see https://github.com/dart-lang/sdk/issues/12688
  void broadcastByteBufer({required ByteBuffer byteBuffer});

  /// same as sendByteBufer as ByteBufer == ArrayBuffer
  ///
  /// FIXME: does it needs to exists?
  /// see https://github.com/dart-lang/sdk/issues/12688
  @Deprecated('Use broadcastByteBufer instead')
  void broadcastArrayBuffer({required ByteBuffer arrayBuffer});

  /// TypedData == ArrayBufferView
  ///
  /// see https://api.dart.dev/stable/2.10.4/dart-html/PushMessageData/arrayBuffer.html
  void broadcastTypedData({required TypedData typedData});

  /// same as sendTypedData as TypedData == ArrayBufferView
  ///
  /// FIXME: does it needs to exists?
  /// see https://api.dart.dev/stable/2.10.4/dart-html/PushMessageData/arrayBuffer.html
  @Deprecated('Use broadcastTypedData instead')
  void broadcastArrayBufferView({required TypedData arrayBufferView});
}
