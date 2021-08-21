part of uhst_sockets;

class SocketHelper {
  SocketHelper({
    required this.relayClient,
    required this.debug,
  }) {
    eventStreamController =
        StreamController<Map<UhstSocketEventType, dynamic>>.broadcast();

    eventStream = eventStreamController.stream;
  }

  late final StreamController<Map<UhstSocketEventType, dynamic>>
      eventStreamController;
  late final Stream<Map<UhstSocketEventType, dynamic>> eventStream;
  final diagntosticListenerHandlers =
      <DiagnosticHandler?, StreamSubscription>{};
  final messageListenerHandlers = <MessageHandler?, StreamSubscription>{};
  final exceptionListenerHandlers = <ExceptionHandler?, StreamSubscription>{};
  final closeListenerHandlers = <CloseHandler?, StreamSubscription>{};
  final openListenerHandlers = <OpenHandler?, StreamSubscription>{};

  String? remoteId;
  String? token;
  String get verifiedToken {
    final vtoken = token;
    if (vtoken == null || vtoken.isEmpty) throw ArgumentError.notNull('token');
    return vtoken;
  }

  final UhstRelayClient relayClient;
  final bool debug;

  String? sendUrl;
  RelayStream? relayMessageStream;

  void emit({required UhstSocketEventType message, dynamic body}) {
    eventStreamController.stream.listen((event) {});
    eventStreamController.add({message: body});
  }

  void emitDiagnostic({dynamic body}) {
    eventStreamController.add({UhstSocketEventType.diagnostic: body});
  }

  void emitException({dynamic body}) {
    eventStreamController.add({UhstSocketEventType.error: body});
  }
}
