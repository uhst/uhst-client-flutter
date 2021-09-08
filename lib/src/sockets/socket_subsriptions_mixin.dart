part of uhst_sockets;

/// Use this mixin for client socket implementations
mixin SocketSubsriptionsMixin implements UhstSocket {
  late final SocketHelper h;

  @override
  void offClose({required CloseHandler handler}) {
    final subsription = h.exceptionListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  @override
  void offDiagnostic({required DiagnosticHandler handler}) {
    final subsription = h.diagntosticListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  @override
  void offException({required ExceptionHandler handler}) {
    final subsription = h.exceptionListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  @override
  void offMessage({required MessageHandler handler}) {
    final subsription = h.messageListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  @override
  void offOpen({required OpenHandler handler}) {
    final subsription = h.openListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  @override
  StreamSubscription<Map<UhstSocketEventType, dynamic>> onClose({
    required CloseHandler handler,
  }) {
    final subsription = h.eventStream.listen((data) {
      if (data.containsKey(UhstSocketEventType.close)) {
        final maybeHostId = data.values.first ?? '';
        handler(hostId: maybeHostId);
      }
    });
    h.closeListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  @override
  StreamSubscription<Map<UhstSocketEventType, dynamic>> onDiagnostic({
    required DiagnosticHandler handler,
  }) {
    final subsription = h.eventStream.listen((data) {
      if (data.containsKey(UhstSocketEventType.diagnostic)) {
        handler(message: data.values.first);
      }
    });
    h.diagntosticListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  @override
  StreamSubscription<Map<UhstSocketEventType, dynamic>> onException({
    required ExceptionHandler handler,
  }) {
    final subsription = h.eventStream.listen((data) {
      if (data.containsKey(UhstSocketEventType.error)) {
        handler(exception: data.values.first);
      }
    });
    h.exceptionListenerHandlers.update(
      handler,
      (value) => subsription,
      ifAbsent: () => subsription,
    );
    return subsription;
  }

  @override
  StreamSubscription<Map<UhstSocketEventType, dynamic>> onMessage({
    required MessageHandler handler,
  }) {
    final subsription = h.eventStream.listen((event) {
      if (event.containsKey(UhstSocketEventType.message)) {
        handler(message: event.values.first);
      }
    });
    h.messageListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  @override
  StreamSubscription<Map<UhstSocketEventType, dynamic>> onOpen({
    required OpenHandler handler,
  }) {
    final subsription = h.eventStream.listen((event) {
      if (event.containsKey(UhstSocketEventType.open)) handler();
    });
    h.openListenerHandlers.update(
      handler,
      (value) => subsription,
      ifAbsent: () => subsription,
    );
    return subsription;
  }

  @override
  void onceClose({required CloseHandler handler}) {
    onClose(handler: handler).onData((data) {
      if (data.containsKey(UhstSocketEventType.close)) {
        offClose(handler: handler);
      }
    });
  }

  @override
  void onceDiagnostic({required DiagnosticHandler handler}) {
    onDiagnostic(handler: handler).onData((data) {
      if (data.containsKey(UhstSocketEventType.diagnostic)) {
        offDiagnostic(handler: handler);
      }
    });
  }

  @override
  void onceException({required ExceptionHandler handler}) {
    onException(handler: handler).onData((data) {
      if (data.containsKey(UhstSocketEventType.error)) {
        offException(handler: handler);
      }
    });
  }

  @override
  void onceMessage({required MessageHandler handler}) {
    onMessage(handler: handler).onData((data) {
      if (data.containsKey(UhstSocketEventType.message)) {
        offMessage(handler: handler);
      }
    });
  }

  @override
  void onceOpen({required OpenHandler handler}) {
    onOpen(handler: handler).onData((data) {
      if (data.containsKey(UhstSocketEventType.open)) offOpen(handler: handler);
    });
  }
}
