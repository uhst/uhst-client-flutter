/// Defines message types for event streams
/// inside host sockets.
///
/// Usage example:
/// ```dart
///
/// /// Event stream
/// final Stream<Map<HostEventType, dynamic>> eventStream;
///
/// /// Event stream controller
/// final StreamController<Map<HostEventType, dynamic>> eventStreamController;
///
/// /// Stream and controller initialization
/// eventStreamController = StreamController<Map<HostEventType, dynamic>>.
/// broadcast();
/// eventStream = eventStreamController.stream;
///
/// /// Send event and message to stream
/// void emit({required HostEventType message, dynamic body}) {
///   eventStreamController.add({message: body});
/// }
///
/// /// Listen event and message
/// eventStream.listen((event) {
///   if (event.containsKey(HostEventType.connection)) {
///     var message = event.values.first;
///     print(message);
///   }
/// });
///
/// ```
enum HostEventType {
  /// Host is ready.
  ready,

  /// A client connected.
  connection,

  /// An error occurred.
  error,

  /// A diagnostic message.
  diagnostic,

  /// The host closed.
  close,
}
