import 'dart:async';

import '../contracts/contracts.dart';
import '../models/models.dart';

/// Helper class for managing socket state and event emission.
class SocketHelper {
  /// Creates a [SocketHelper].
  SocketHelper({
    required this.relayClient,
    required this.debug,
  }) {
    eventStreamController =
        StreamController<Map<UhstSocketEventType, dynamic>>.broadcast();
  }

  /// The event stream controller.
  late final StreamController<Map<UhstSocketEventType, dynamic>>
      eventStreamController;

  /// The event stream.
  Stream<Map<UhstSocketEventType, dynamic>> get eventStream =>
      eventStreamController.stream;

  /// Diagnostic listener handlers.
  final diagntosticListenerHandlers =
      <DiagnosticHandler?, StreamSubscription>{};

  /// Message listener handlers.
  final messageListenerHandlers = <MessageHandler?, StreamSubscription>{};

  /// Exception listener handlers.
  final exceptionListenerHandlers = <ExceptionHandler?, StreamSubscription>{};

  /// Close listener handlers.
  final closeListenerHandlers = <CloseHandler?, StreamSubscription>{};

  /// Open listener handlers.
  final openListenerHandlers = <OpenHandler?, StreamSubscription>{};

  /// The remote peer ID.
  String? remoteId;

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
  void emit({
    required UhstSocketEventType message,
    dynamic body,
  }) {
    eventStreamController.add({message: body});
  }

  /// Emit a diagnostic event.
  void emitDiagnostic({dynamic body}) {
    eventStreamController.add({UhstSocketEventType.diagnostic: body});
  }

  /// Emit an exception event.
  void emitException({dynamic body}) {
    eventStreamController.add({UhstSocketEventType.error: body});
  }
}
