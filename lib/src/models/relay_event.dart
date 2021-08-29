part of uhst_models;

enum RelayEventType {
  //  CLIENT_CLOSED = 'client_closed',
  //  HOST_CLOSED = 'host_closed',
  clientClosed,
  hostClosed,
}

@immutable

/// Special events sending by relay.
/// Used to notify about [RelayEventType] events
class RelayEvent extends Message {
  const RelayEvent({
    required this.eventType,
    required String payload,
    required PayloadType type,
    String? responseToken,
  }) : super(
          payload: payload,
          type: type,
          responseToken: responseToken,
        );

  factory RelayEvent.fromJson(dynamic json) {
    final jsonMap = jsonDecode(json);
    if (jsonMap is! Map<String, String>) {
      throw ArgumentError.value(jsonMap, 'json', 'has to be map');
    }
    final message = Message.fromJson(jsonMap);
    return RelayEvent.fromMessageAndJson(
      json: json,
      message: message,
    );
  }

  RelayEvent.fromMessageAndJson({
    required Message message,
    required Map<String, dynamic> json,
  })  : eventType = json['eventType'],
        super(
            payload: message.payload,
            type: message.type,
            responseToken: message.responseToken);

  final RelayEventType eventType;
}
