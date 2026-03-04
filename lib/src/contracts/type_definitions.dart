/// Defines callback to handle [FromJson] function.
/// This function is needed to convert [Map] in defined type or model.
typedef FromJson<T> = T Function(dynamic map);

/// [PayloadType] is a type of message data which can be sent and handled by
/// Client (for example [RelaySocket]) or by Host [UhstHost].
///
/// Use [PayloadType.fromString] to convert a string to enum value:
///
/// ```dart
/// PayloadType.fromString('string');
/// ```
///
/// Use [toStringValue] to get the string value:
///
/// ```dart
/// PayloadType.string.toStringValue() // output: 'string'
/// ```
enum PayloadType {
  /// String payload type.
  string,

  /// Blob payload type.
  blob,

  /// ByteBuffer payload type.
  byteBuffer,

  /// TypedData payload type.
  typedData;

  /// Convert from string to enum value.
  static PayloadType fromString(String value) => PayloadType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => throw ArgumentError('Unknown PayloadType: $value'),
      );

  /// Returns string for enum value.
  String toStringValue() => name;
}
