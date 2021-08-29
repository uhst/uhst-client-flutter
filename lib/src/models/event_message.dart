part of uhst_models;

@immutable
class EventMessage {
  const EventMessage({
    required this.body,
    required this.responseToken,
  });
  factory EventMessage.fromJson(Map<dynamic, dynamic> map) {
    final message = Message.fromJson(map['body']);
    final responseToken = map['responseToken'] ?? '';
    final effectiveMessage = message.copyWith(responseToken: responseToken);
    return EventMessage(body: effectiveMessage, responseToken: responseToken);
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
