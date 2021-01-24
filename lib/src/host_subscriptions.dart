library UHST;

import 'dart:async';

import 'host_helper.dart';
import 'uhst_host_event.dart';

mixin HostSubsriptions {
  late final HostHelper h;

  void offConnection({required handler}) {
    var subsription = h.connectionListenerHandlers.remove(handler);
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

  void offReady({required handler}) {
    var subsription = h.readyListenerHandlers.remove(handler);
    subsription?.cancel();
  }

  StreamSubscription<Map<HostEventType, String>> onConnection(
      {required handler}) {
    var subsription = h.eventStream.listen((event) {
      if (event.containsKey(HostEventType.connection)) {
        handler(data: event.values.first);
      }
    });
    h.connectionListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  StreamSubscription<Map<HostEventType, String>> onDiagnostic(
      {required handler}) {
    var subsription = h.eventStream.listen((event) {});
    subsription.onData((data) {
      if (data.containsKey(HostEventType.diagnostic)) {
        handler(message: data.values.first);
      }
    });
    h.diagntosticListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  StreamSubscription<Map<HostEventType, String>> onError({required handler}) {
    var subsription = h.eventStream.listen((event) {});
    subsription.onData((data) {
      if (data.containsKey(HostEventType.error)) {
        handler(error: ArgumentError(data.values.first));
      }
    });
    h.errorListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  StreamSubscription<Map<HostEventType, String>> onReady({required handler}) {
    var subsription = h.eventStream.listen((event) {
      if (event.containsKey(HostEventType.ready))
        handler(data: event.values.first);
    });
    h.readyListenerHandlers
        .update(handler, (value) => subsription, ifAbsent: () => subsription);
    return subsription;
  }

  void onceConnection({required handler}) {
    var subscription = onConnection(handler: handler);
    subscription.onData((data) {
      if (data.containsKey(HostEventType.connection))
        offConnection(handler: handler);
    });
  }

  void onceDiagnostic({required handler}) {
    var subscription = onDiagnostic(handler: handler);
    subscription.onData((data) {
      if (data.containsKey(HostEventType.diagnostic))
        offDiagnostic(handler: handler);
    });
  }

  void onceError({required handler}) {
    var subscription = onError(handler: handler);
    subscription.onData((data) {
      if (data.containsKey(HostEventType.error)) offError(handler: handler);
    });
  }

  void onceReady({required handler}) {
    var subscription = onReady(handler: handler);
    subscription.onData((data) {
      if (data.containsKey(HostEventType.ready)) offReady(handler: handler);
    });
  }
}
