part of uhst_models;

@immutable
class Message {
  const Message({
    required this.type,
    required this.payload,
    this.responseToken,
  });

  /// Use to restore [Message] from json
  factory Message.fromJson(Map<dynamic, dynamic> map) {
    final PayloadType verifiedPayloadType = (() {
      final _payloadType = map['type'];
      if (_payloadType == null ||
          _payloadType is! String ||
          (_payloadType is String && _payloadType.isEmpty)) {
        return PayloadType.string;
      }
      return PayloadType.fromString[_payloadType];
    })();

    return Message(
        payload: map['payload'],
        type: verifiedPayloadType,
        responseToken: map['responseToken'] ?? '');
  }
  final PayloadType type;
  final String payload;
  final String? responseToken;

  /// Use to encode [Message] to json
  Map<String, String?> toJson() => {
        'type': type.toStringValue(),
        'payload': payload,
        'responseToken': responseToken,
      };

  /// Use this to get modified message
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
