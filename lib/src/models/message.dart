import 'package:meta/meta.dart';

import '../contracts/type_definitions.dart';

/// Core message class for UHST communication.
@immutable
class Message {
  /// Creates a [Message].
  const Message({
    required this.type,
    required this.payload,
    this.responseToken,
  });

  /// Use to restore [Message] from json.
  factory Message.fromJson(Map<dynamic, dynamic> map) {
    final PayloadType verifiedPayloadType = (() {
      final payloadType = map['type'];
      if (payloadType == null ||
          payloadType is! String ||
          payloadType.isEmpty) {
        return PayloadType.string;
      }
      return PayloadType.fromString(payloadType);
    })();

    return Message(
      payload: map['payload'],
      type: verifiedPayloadType,
      responseToken: map['responseToken'] ?? '',
    );
  }

  /// The payload type.
  final PayloadType type;

  /// The message payload.
  final String payload;

  /// The response token.
  final String? responseToken;

  /// Use to encode [Message] to json.
  Map<String, String?> toJson() => {
        'type': type.toStringValue(),
        'payload': payload,
        'responseToken': responseToken,
      };

  /// Use this to get a modified message.
  Message copyWith({
    final PayloadType? type,
    final String? payload,
    final String? responseToken,
  }) =>
      Message(
        payload: payload ?? this.payload,
        type: type ?? this.type,
        responseToken: responseToken ?? this.responseToken,
      );

  @override
  String toString() => '${toJson()}';
}
