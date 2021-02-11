import 'message.dart';

class EventMessage {
  final Message? body;
  final String responseToken;

  EventMessage({required this.body, required this.responseToken});

  factory EventMessage.fromJson(Map<dynamic, dynamic> map) {
    var message = Message.fromJson(map['body']);
    var responseToken = map['responseToken'] ?? '';
    message.responseToken = responseToken;
    return EventMessage(body: message, responseToken: responseToken);
  }

  toJson() {
    return {
      'body': body?.toJson(),
      'responseToken': responseToken,
    };
  }

  @override
  String toString() => '${toJson()}';
}
