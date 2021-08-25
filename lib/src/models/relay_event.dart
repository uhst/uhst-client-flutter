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

  final RelayEventType eventType;
}
