import 'dart:async';

import '../contracts/contracts.dart';
import '../models/models.dart';

/// Helper class for managing host state and event emission.
class HostHelper {
  /// Creates a [HostHelper].
  HostHelper({
    required this.relayClient,
    required this.debug,
  }) {
    eventStreamController =
        StreamController<Map<HostEventType, dynamic>>.broadcast();
  }

  /// The event stream controller.
  late final StreamController<Map<HostEventType, dynamic>>
      eventStreamController;

  /// The event stream.
  Stream<Map<HostEventType, dynamic>> get eventStream =>
      eventStreamController.stream;

  /// Diagnostic listener handlers.
  final diagntosticListenerHandlers =
      <DiagnosticHandler?, StreamSubscription>{};

  /// Exception listener handlers.
  final exceptionListenerHandlers = <ExceptionHandler?, StreamSubscription>{};

  /// Close listener handlers.
  final closeListenerHandlers = <CloseHandler?, StreamSubscription>{};

  /// Ready listener handlers.
  final readyListenerHandlers = <HostReadyHandler?, StreamSubscription>{};

  /// Connection listener handlers.
  final connectionListenerHandlers =
      <HostConnectionHandler?, StreamSubscription>{};

  /// The token.
  String token = '';

  /// The verified token.
  String get verifiedToken {
    if (token.isEmpty) {
      throw ArgumentError.value(token, 'token', 'isEmpty');
    }
    return token;
  }

  /// The relay client.
  final UhstRelayClient relayClient;

  /// Whether debug mode is enabled.
  final bool debug;

  /// The send URL.
  String? sendUrl;

  /// The relay message stream.
  RelayStream? relayMessageStream;

  /// Emit an event.
  void emit({required HostEventType message, dynamic body}) {
    eventStreamController.add({message: body});
  }

  /// Emit a diagnostic event.
  void emitDiagnostic({dynamic body}) {
    eventStreamController.add({HostEventType.diagnostic: body});
  }

  /// Emit an exception event.
  void emitException({dynamic body}) {
    eventStreamController.add({HostEventType.error: body});
  }
}
