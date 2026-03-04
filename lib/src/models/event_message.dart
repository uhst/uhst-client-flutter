import 'package:meta/meta.dart';

import 'message.dart';

/// Wrapper for messages with response tokens.
@immutable
class EventMessage {
  /// Creates an [EventMessage].
  const EventMessage({
    required this.body,
    required this.responseToken,
  });

  /// Creates an [EventMessage] from JSON.
  factory EventMessage.fromJson(Map<dynamic, dynamic> map) {
    final message = Message.fromJson(map['body']);
    final responseToken = map['responseToken'] ?? '';
    final effectiveMessage = message.copyWith(responseToken: responseToken);
    return EventMessage(
      body: effectiveMessage,
      responseToken: responseToken,
    );
  }

  /// The message body.
  final Message body;

  /// The response token.
  final String responseToken;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'body': body.toJson(),
        'responseToken': responseToken,
      };

  @override
  String toString() => '${toJson()}';
}
