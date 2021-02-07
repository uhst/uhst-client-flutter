library uhst;

import 'package:flutter/foundation.dart';

/// Defines callback to handle [FromJson] function
/// This function is needed to convert [Map] in defined type or model
typedef T FromJson<T>(Map<String, dynamic> map);

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

extension PayloadTypeDescribe on PayloadType {
  /// Overload the [] getter to get the name of the fruit.
  /// based on https://stackoverflow.com/a/60209631
  operator [](String key) => (name) {
        switch (name) {
          case 'string':
            return PayloadType.string;
          case 'blob':
            return PayloadType.blob;
          case 'byteBuffer':
            return PayloadType.blob;
          case 'typedData':
            return PayloadType.blob;
          default:
            throw RangeError("enum PayloadType contains no value '$name'");
        }
      }(key);

  /// returns string for enum value only
  String toStringValue() => describeEnum(this);
}
