part of uhst_models;

enum RelayEventType {
  //  CLIENT_CLOSED = 'client_closed',
  //  HOST_CLOSED = 'host_closed',
  clientClosed,
  hostClosed,
}

class RelayEvent extends Message {
  RelayEvent({
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
    if (json is! Map<String, dynamic>) {
      throw ArgumentError.value(json, 'json', 'has to be map');
    }
    final message = Message.fromJson(json);
    return RelayEvent.fromMessageAndJson(json: json, message: message);
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
