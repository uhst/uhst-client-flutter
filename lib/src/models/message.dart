part of uhst_models;

class Message {
  Message({
    required this.type,
    required this.payload,
    this.responseToken,
  });
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
  String? responseToken;

  Map<String, String?> toJson() => {
        'type': type.toStringValue(),
        'payload': payload,
        'responseToken': responseToken,
      };

  @override
  String toString() => '${toJson()}';
}
