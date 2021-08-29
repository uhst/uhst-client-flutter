part of uhst_models;

enum RelayEventType {
  //  CLIENT_CLOSED = 'client_closed',
  //  HOST_CLOSED = 'host_closed',
  clientClosed,
  hostClosed,
}

@immutable

/// Special events sent by relay.
/// Used to notify host or client about [RelayEventType] events
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
    if (jsonMap is! Map<String, dynamic>) {
      throw ArgumentError.value(jsonMap, 'json', 'has to be map');
    }
    return RelayEvent(
      eventType: jsonMap['eventType'],
      payload: jsonMap['body'],
      type: PayloadType.string,
    );
  }

  final RelayEventType eventType;
}
