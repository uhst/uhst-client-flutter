part of uhst_hosts;

class HostHelper {
  HostHelper({
    required this.relayClient,
    required this.debug,
  }) {
    eventStreamController =
        StreamController<Map<HostEventType, dynamic>>.broadcast();
  }
  late final StreamController<Map<HostEventType, dynamic>>
      eventStreamController;
  Stream<Map<HostEventType, dynamic>> get eventStream =>
      eventStreamController.stream;
  final diagntosticListenerHandlers =
      <DiagnosticHandler?, StreamSubscription>{};
  final exceptionListenerHandlers = <ExceptionHandler?, StreamSubscription>{};
  final closeListenerHandlers = <CloseHandler?, StreamSubscription>{};
  final readyListenerHandlers = <HostReadyHandler?, StreamSubscription>{};
  final connectionListenerHandlers =
      <HostConnectionHandler?, StreamSubscription>{};

  String token = '';
  String get verifiedToken {
    if (token.isEmpty) throw ArgumentError.value(token, 'token', 'isEmpty');
    return token;
  }

  final UhstRelayClient relayClient;
  final bool debug;

  String? sendUrl;
  RelayStream? relayMessageStream;

  void emit({required HostEventType message, dynamic body}) {
    eventStreamController.add({message: body});
  }

  void emitDiagnostic({dynamic body}) {
    eventStreamController.add({HostEventType.diagnostic: body});
  }

  void emitException({dynamic body}) {
    eventStreamController.add({HostEventType.error: body});
  }
}
