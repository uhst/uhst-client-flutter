library uhst;

import 'dart:async';

import 'package:universal_html/html.dart';

import '../contracts/uhst_api_client.dart';
import '../contracts/uhst_event_handlers.dart';
import '../contracts/uhst_socket_events.dart';

class SocketHelper {
  late final StreamController<Map<UhstSocketEventType, dynamic>>
      eventStreamController;
  late final Stream<Map<UhstSocketEventType, dynamic>> eventStream;
  final diagntosticListenerHandlers =
      <DiagnosticHandler?, StreamSubscription>{};
  final messageListenerHandlers = <MessageHandler?, StreamSubscription>{};
  final errorListenerHandlers = <ErrorHandler?, StreamSubscription>{};
  final closeListenerHandlers = <CloseHandler?, StreamSubscription>{};
  final openListenerHandlers = <OpenHandler?, StreamSubscription>{};

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

  void emit({required UhstSocketEventType message, dynamic body}) {
    eventStreamController.stream.listen((event) {});
    eventStreamController.add({message: body});
  }

  void emitDiagnostic({dynamic body}) {
    eventStreamController.add({UhstSocketEventType.diagnostic: body});
  }

  void emitError({dynamic body}) {
    eventStreamController.add({UhstSocketEventType.error: body});
  }
}
