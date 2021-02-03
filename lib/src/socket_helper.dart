library uhst;

import 'dart:async';

import 'package:uhst/src/uhst_event_handlers.dart';
import 'package:universal_html/html.dart';

import 'contracts/uhst_api_client.dart';
import 'contracts/uhst_socket_events.dart';

class SocketHelper {
  late final StreamController<Map<UhstSocketEventType, dynamic>>
      eventStreamController;
  late final Stream<Map<UhstSocketEventType, dynamic>> eventStream;
  Map<DiagnosticHandler?, StreamSubscription> diagntosticListenerHandlers =
      Map();
  Map<MessageHandler?, StreamSubscription> messageListenerHandlers = Map();
  Map<ErrorHandler?, StreamSubscription> errorListenerHandlers = Map();
  Map<CloseHandler?, StreamSubscription> closeListenerHandlers = Map();
  Map<OpenHandler?, StreamSubscription> openListenerHandlers = Map();

  void emit({required UhstSocketEventType message, dynamic body}) {
    eventStreamController.stream.listen((event) {
      if (debug) print({'stream message': event});
    });
    eventStreamController.add({message: body});
  }

  void emitDiagnostic({dynamic body}) {
    eventStreamController.add({UhstSocketEventType.diagnostic: body});
  }

  void emitError({dynamic body}) {
    eventStreamController.add({UhstSocketEventType.error: body});
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
  SocketHelper({
    required this.apiClient,
    required this.debug,
  }) {
    eventStreamController =
        StreamController<Map<UhstSocketEventType, dynamic>>.broadcast();

    eventStream = eventStreamController.stream;
  }
}
