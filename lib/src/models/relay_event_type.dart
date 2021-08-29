part of uhst_models;

/// Relay(Server) events happened on host or client side
/// As all events are in snake_case they will be converted automatically
/// to camelCase
enum RelayEventType {
  /// Server event name 'client_closed',
  clientClosed,

  /// Server event name 'host_closed',
  hostClosed,

  /// _from is used to get valid enum property from string
  /// example:
  ///
  /// ```dart
  /// RelayEventType.fromString['string'];
  /// ```
  ///
  /// to get string value use toStringValue
  /// example:
  ///
  /// ```dart
  /// RelayEventType.string.toStringValue() // output: 'string'
  /// ```
  ///
  fromJson,
}

///
extension RelayEventTypeDescribe on RelayEventType {
  /// Overload the [] getter to get the name of the fruit.
  /// based on https://stackoverflow.com/a/60209631
  RelayEventType operator [](String key) => getEnumValueFromEnumValues(
        values: RelayEventType.values,
        value: key.camelCase,
      );

  /// returns string for enum value only
  String toStringValue() => describeEnum(this).snakeCase;
}
