/// Defines message types for event streams
/// inside client sockets.
///
/// Usage example:
/// ```dart
///
/// /// Event stream
/// final Stream<Map<UhstSocketEventType, dynamic>> eventStream;
///
/// /// Event stream controller
/// final StreamController<Map<UhstSocketEventType, dynamic>>
/// eventStreamController;
///
/// /// Stream and controller initialization
/// eventStreamController = StreamController<Map<UhstSocketEventType,
/// dynamic>>.broadcast();
/// eventStream = eventStreamController.stream;
///
/// /// Send event and message to stream
/// void emit({required UhstSocketEventType message, dynamic body}) {
///   eventStreamController.add({message: body});
/// }
///
/// /// Listen event and message
/// eventStream.listen((event) {
///   if (event.containsKey(UhstSocketEventType.connection)) {
///     var message = event.values.first;
///     print(message);
///   }
/// });
///
/// ```
enum UhstSocketEventType {
  /// An error occurred.
  error,

  /// A message received.
  message,

  /// Connection opened.
  open,

  /// Connection closed.
  close,

  /// A diagnostic message.
  diagnostic,
}
