part of uhst_contracts;

abstract class UhstSocket {
  String? get remoteId;
  void onOpen({required OpenHandler handler});
  void onMessage({required MessageHandler handler});
  void onException({required ExceptionHandler handler});
  void onClose({required CloseHandler handler});
  void onDiagnostic({required DiagnosticHandler handler});

  void onceOpen({required OpenHandler handler});
  void onceMessage({required MessageHandler handler});
  void onceException({required ExceptionHandler handler});
  void onceClose({required CloseHandler handler});
  void onceDiagnostic({required DiagnosticHandler handler});

  void offOpen({required OpenHandler handler});
  void offMessage({required MessageHandler handler});
  void offException({required ExceptionHandler handler});
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
  @Deprecated('Use sendByteBufer instead')
  void sendArrayBuffer({required ByteBuffer arrayBuffer});

  /// TypedData == ArrayBufferView
  ///
  /// see https://api.dart.dev/stable/2.10.4/dart-html/PushMessageData/arrayBuffer.html
  void sendTypedData({required TypedData typedData});

  /// same as sendTypedData as TypedData == ArrayBufferView
  ///
  /// FIXME: does it needs to exists?
  /// see https://api.dart.dev/stable/2.10.4/dart-html/PushMessageData/arrayBuffer.html
  @Deprecated('Use sendTypedData instead')
  void sendArrayBufferView({required TypedData arrayBufferView});

  /// This method is using to close EventSource.
  /// Before close will be fired [onClose] [onceClose]
  /// will be called, if any provided

  void close();

  /// This method should be called during dispose method in Flutter widget
  /// or any another cases that require to cancel all subscriptions and
  /// all methods
  ///
  /// This method will started with [close] call
  ///
  /// In Flutter you can add such methods in dispose override.
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   client?.dispose();
  ///   host?.dispose();
  ///   super.dispose();
  /// }
  /// ```
  ///
  void dispose();
  void onClientMessage({required Message message});
}
