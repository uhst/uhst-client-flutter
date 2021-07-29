part of uhst_models;

class EventMessage {
  EventMessage({
    required this.body,
    required this.responseToken,
  });
  factory EventMessage.fromJson(Map<dynamic, dynamic> map) {
    final message = Message.fromJson(map['body']);
    final responseToken = map['responseToken'] ?? '';
    message.responseToken = responseToken;
    return EventMessage(body: message, responseToken: responseToken);
  }
  final Message body;
  final String responseToken;

  Map<String, dynamic> toJson() => {
        'body': body.toJson(),
        'responseToken': responseToken,
      };

  @override
  String toString() => '${toJson()}';
}
