library uhst;

import '../contracts/type_definitions.dart';

class Message {
  final PayloadType type;
  final String payload;
  String? responseToken;
  Message({required this.type, required this.payload, this.responseToken});
  factory Message.fromJson(Map<dynamic, dynamic> map) {
    PayloadType verifiedPayloadType = (() {
      String? _payloadType = map['type'];
      if (_payloadType == null || _payloadType.isEmpty)
        return PayloadType.string;
      return PayloadType.fromString[_payloadType];
    })();

    return Message(
        payload: map['payload'],
        type: verifiedPayloadType,
        responseToken: map['responseToken'] ?? '');
  }

  toJson() {
    return {
      'type': type.toStringValue(),
      'payload': payload,
      'responseToken': responseToken,
    };
  }

  @override
  String toString() => '${toJson()}';
}
