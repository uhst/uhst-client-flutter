part of uhst_contracts;

/// Defines callback to handle [FromJson] function
/// This function is needed to convert [Map] in defined type or model
typedef FromJson<T> = T Function(Map<String, dynamic> map);

/// [PayloadType] is a type of message data which can be send and handled by
/// Client (for example [RelaySocket] or by Host [UhstHost]
///
/// _from is used to get valid enum property from string
/// example:
///
/// ```dart
/// PayloadType.fromString['string'];
/// ```
///
/// to get string value use toStringValue
/// example:
///
/// ```dart
/// PayloadType.string.toStringValue() // output: 'string'
/// ```
///
enum PayloadType { fromString, string, blob, byteBuffer, typedData }

///
extension PayloadTypeDescribe on PayloadType {
  /// Overload the [] getter to get the name of the fruit.
  /// based on https://stackoverflow.com/a/60209631
  PayloadType operator [](String key) => getEnumValueFromEnumValues(
        values: PayloadType.values,
        value: key,
      );

  /// returns string for enum value only
  // TODO(arenukvern): remove this when Dart will reach 2.14
  String toStringValue() => describeEnum(this);
}
