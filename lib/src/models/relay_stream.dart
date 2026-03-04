import 'package:universal_html/html.dart';

/// Wraps an [EventSource] for relay communication.
class RelayStream {
  /// Creates a [RelayStream].
  RelayStream({required this.eventSource});

  /// The underlying event source.
  final EventSource eventSource;

  /// Closes the event source.
  void close() {
    eventSource.close();
  }
}
