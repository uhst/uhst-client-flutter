part of uhst_sockets;

class SocketHelper {
  SocketHelper({
    required this.relayClient,
    required this.debug,
  }) {
    eventStreamController =
        StreamController<Map<UhstSocketEventType, dynamic>>.broadcast();
  }

  late final StreamController<Map<UhstSocketEventType, dynamic>>
      eventStreamController;
  Stream<Map<UhstSocketEventType, dynamic>> get eventStream =>
      eventStreamController.stream;
  final diagntosticListenerHandlers =
      <DiagnosticHandler?, StreamSubscription>{};
  final messageListenerHandlers = <MessageHandler?, StreamSubscription>{};
  final exceptionListenerHandlers = <ExceptionHandler?, StreamSubscription>{};
  final closeListenerHandlers = <CloseHandler?, StreamSubscription>{};
  final openListenerHandlers = <OpenHandler?, StreamSubscription>{};

  String? remoteId;
  String token = '';
  String get verifiedToken {
    if (token.isEmpty) throw ArgumentError.value(token, 'token', 'isEmpty');
    return token;
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
