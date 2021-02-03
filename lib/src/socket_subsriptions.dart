library uhst;

import 'dart:async';

import 'contracts/uhst_socket.dart';
import 'contracts/uhst_socket_events.dart';
import 'socket_helper.dart';

mixin SocketSubsriptions implements UhstSocket {
  late final SocketHelper h;

  void offClose({required handler}) {
    var subsription = h.errorListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  void offDiagnostic({required handler}) {
    var subsription = h.diagntosticListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  void offError({required handler}) {
    var subsription = h.errorListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  void offMessage({required handler}) {
    var subsription = h.messageListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  void offOpen({required handler}) {
    var subsription = h.openListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  StreamSubscription<Map<UhstSocketEventType, dynamic>> onClose(
      {required handler}) {
    var subsription = h.eventStream.listen((event) {});
    subsription.onData((data) {
      if (data.containsKey(UhstSocketEventType.close)) {
        handler();
      }
    });
    h.closeListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  StreamSubscription<Map<UhstSocketEventType, dynamic>> onDiagnostic(
      {required handler}) {
    var subsription = h.eventStream.listen((event) {});
    subsription.onData((data) {
      if (data.containsKey(UhstSocketEventType.diagnostic)) {
        handler(message: data.values.first);
      }
    });
    h.diagntosticListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  StreamSubscription<Map<UhstSocketEventType, dynamic>> onError(
      {required handler}) {
    var subsription = h.eventStream.listen((event) {});
    subsription.onData((data) {
      if (data.containsKey(UhstSocketEventType.error)) {
        handler(error: ArgumentError(data.values.first));
      }
    });
    h.errorListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  StreamSubscription<Map<UhstSocketEventType, dynamic>> onMessage(
      {required handler}) {
    var subsription = h.eventStream.listen((event) {
      if (event.containsKey(UhstSocketEventType.message)) {
        handler(message: event.values.first);
      }
    });
    h.messageListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  StreamSubscription<Map<UhstSocketEventType, dynamic>> onOpen(
      {required handler}) {
    var subsription = h.eventStream.listen((event) {
      if (event.containsKey(UhstSocketEventType.open))
        handler(data: event.values.first);
    });
    h.openListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  void onceClose({required handler}) {
    var subscription = onClose(handler: handler);
    subscription.onData((data) {
      if (data.containsKey(UhstSocketEventType.close))
        offClose(handler: handler);
    });
  }

  void onceDiagnostic({required handler}) {
    var subscription = onDiagnostic(handler: handler);
    subscription.onData((data) {
      if (data.containsKey(UhstSocketEventType.diagnostic))
        offDiagnostic(handler: handler);
    });
  }

  void onceError({required handler}) {
    var subscription = onError(handler: handler);
    subscription.onData((data) {
      if (data.containsKey(UhstSocketEventType.error))
        offError(handler: handler);
    });
  }

  void onceMessage({required handler}) {
    var subscription = onMessage(handler: handler);
    subscription.onData((data) {
      if (data.containsKey(UhstSocketEventType.message))
        offMessage(handler: handler);
    });
  }

  void onceOpen({required handler}) {
    var subscription = onOpen(handler: handler);
    subscription.onData((data) {
      if (data.containsKey(UhstSocketEventType.open)) offOpen(handler: handler);
    });
  }
}
