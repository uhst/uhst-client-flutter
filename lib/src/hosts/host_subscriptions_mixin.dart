part of uhst_hosts;

/// Use this mixin to implement HostSocket
mixin HostSubsriptionsMixin implements UhstHostSocket {
  late final HostHelper h;

  @override
  void offClose({required CloseHandler handler}) {
    final subscription = h.closeListenerHandlers.remove(handler);
    subscription?.cancel();
  }

  @override
  void offConnection({required HostConnectionHandler handler}) {
    final subsription = h.connectionListenerHandlers.remove(handler);
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
  void offReady({required HostReadyHandler handler}) {
    final subsription = h.readyListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  @override
  StreamSubscription<Map<HostEventType, dynamic>> onClose(
      {required CloseHandler handler}) {
    final subsription = h.eventStream.listen((event) {
      if (event.containsKey(HostEventType.close)) {
        final maybeHostId = event.values.first ?? '';
        handler(hostId: maybeHostId);
      }
    });
    h.closeListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  @override
  StreamSubscription<Map<HostEventType, dynamic>> onConnection({
    required HostConnectionHandler handler,
  }) {
    final subsription = h.eventStream.listen((event) {
      if (event.containsKey(HostEventType.connection)) {
        final maybeSocket = event.values.first;
        if (maybeSocket is UhstSocket) {
          handler(uhstSocket: maybeSocket);
        }
      }
    });
    h.connectionListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  @override
  StreamSubscription<Map<HostEventType, dynamic>> onDiagnostic({
    required DiagnosticHandler handler,
  }) {
    final subsription = h.eventStream.listen((event) {})
      ..onData((data) {
        if (data.containsKey(HostEventType.diagnostic)) {
          handler(message: data.values.first);
        }
      });
    h.diagntosticListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  @override
  StreamSubscription<Map<HostEventType, dynamic>> onException({
    required ExceptionHandler handler,
  }) {
    final subsription = h.eventStream.listen((event) {})
      ..onData((data) {
        if (data.containsKey(HostEventType.error)) {
          handler(exception: data.values.first);
        }
      });
    h.exceptionListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  @override
  StreamSubscription<Map<HostEventType, dynamic>> onReady({
    required HostReadyHandler handler,
  }) {
    final subsription = h.eventStream.listen((event) {
      if (event.containsKey(HostEventType.ready)) {
        handler(hostId: event.values.first);
      }
    });
    h.readyListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  @override
  void onceConnection({required HostConnectionHandler handler}) {
    onConnection(handler: handler).onData((data) {
      if (data.containsKey(HostEventType.connection)) {
        offConnection(handler: handler);
      }
    });
  }

  @override
  void onceClose({required CloseHandler handler}) {
    onClose(handler: handler).onData((data) {
      if (data.containsKey(HostEventType.close)) {
        offClose(handler: handler);
      }
    });
  }

  @override
  void onceDiagnostic({required DiagnosticHandler handler}) {
    onDiagnostic(handler: handler).onData((data) {
      if (data.containsKey(HostEventType.diagnostic)) {
        offDiagnostic(handler: handler);
      }
    });
  }

  @override
  void onceException({required ExceptionHandler handler}) {
    onException(handler: handler).onData((data) {
      if (data.containsKey(HostEventType.error)) offException(handler: handler);
    });
  }

  @override
  void onceReady({required HostReadyHandler handler}) {
    onReady(handler: handler).onData((data) {
      if (data.containsKey(HostEventType.ready)) offReady(handler: handler);
    });
  }
}
