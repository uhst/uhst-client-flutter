library uhst;

import 'dart:async';

import 'package:uhst/src/uhst_event_handlers.dart';
import 'package:uhst/src/uhst_host_event.dart';
import 'package:universal_html/html.dart';

import 'contracts/uhst_api_client.dart';

class HostHelper {
  late final StreamController<Map<HostEventType, dynamic>>
      eventStreamController;
  late final Stream<Map<HostEventType, dynamic>> eventStream;
  Map<DiagnosticHandler?, StreamSubscription> diagntosticListenerHandlers =
      Map();
  Map<ErrorHandler?, StreamSubscription> errorListenerHandlers = Map();
  Map<CloseHandler?, StreamSubscription> closeListenerHandlers = Map();
  Map<HostReadyHandler?, StreamSubscription> readyListenerHandlers = Map();
  Map<HostConnectionHandler?, StreamSubscription> connectionListenerHandlers =
      Map();

  void emit({required HostEventType message, dynamic body}) {
    eventStreamController.add({message: body});
  }

  void emitDiagnostic({dynamic body}) {
    eventStreamController.add({HostEventType.diagnostic: body});
  }

  void emitError({dynamic body}) {
    eventStreamController.add({HostEventType.error: body});
  }

  String? token;
  String get verifiedToken {
    var vtoken = token;
    if (vtoken == null) throw NullThrownError();
    if (vtoken.isEmpty) throw ArgumentError('Token is empty!');
    return vtoken;
  }

  final UhstApiClient apiClient;
  final bool debug;

  String? sendUrl;
  EventSource? apiMessageStream;
  HostHelper({
    required this.apiClient,
    required this.debug,
  }) {
    eventStreamController =
        StreamController<Map<HostEventType, dynamic>>.broadcast();

    eventStream = eventStreamController.stream;
  }
}
