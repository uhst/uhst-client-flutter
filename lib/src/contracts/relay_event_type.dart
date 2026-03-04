import 'package:recase/recase.dart';

/// Relay(Server) events happened on host or client side.
/// As all events are in snake_case they will be converted automatically
/// to camelCase.
enum RelayEventType {
  /// Server event name 'client_closed'.
  clientClosed,

  /// Server event name 'host_closed'.
  hostClosed;

  /// Convert from snake_case string to enum value.
  static RelayEventType fromString(String value) =>
      RelayEventType.values.firstWhere(
        (e) => e.name == value.camelCase,
        orElse: () => throw ArgumentError('Unknown RelayEventType: $value'),
      );

  /// Returns snake_case string for enum value.
  String toStringValue() => name.snakeCase;
}
