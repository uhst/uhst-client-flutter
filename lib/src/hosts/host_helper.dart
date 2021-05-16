library uhst;

import 'dart:async';

import '../models/relay_stream.dart';
import '../contracts/uhst_relay_client.dart';
import '../contracts/uhst_event_handlers.dart';
import '../contracts/uhst_host_event.dart';

class HostHelper {
  late final StreamController<Map<HostEventType, dynamic>>
      eventStreamController;
  late final Stream<Map<HostEventType, dynamic>> eventStream;
  final diagntosticListenerHandlers =
      <DiagnosticHandler?, StreamSubscription>{};
  final errorListenerHandlers = <ErrorHandler?, StreamSubscription>{};
  final closeListenerHandlers = <CloseHandler?, StreamSubscription>{};
  final readyListenerHandlers = <HostReadyHandler?, StreamSubscription>{};
  final connectionListenerHandlers =
      <HostConnectionHandler?, StreamSubscription>{};

  String? token;
  String get verifiedToken {
    var vtoken = token;
    if (vtoken == null || vtoken.isEmpty)
      throw ArgumentError('Token is empty or null!');
    return vtoken;
  }

  final UhstRelayClient relayClient;
  final bool debug;

  String? sendUrl;
  RelayStream? relayMessageStream;
  HostHelper({
    required this.relayClient,
    required this.debug,
  }) {
    eventStreamController =
        StreamController<Map<HostEventType, dynamic>>.broadcast();

    eventStream = eventStreamController.stream;
  }

  void emit({required HostEventType message, dynamic body}) {
    eventStreamController.add({message: body});
  }

  void emitDiagnostic({dynamic body}) {
    eventStreamController.add({HostEventType.diagnostic: body});
  }

  void emitError({dynamic body}) {
    eventStreamController.add({HostEventType.error: body});
  }
}
