part of uhst_clients;

class _RelayClientConsts {
  static const requestHeaderContentName = 'Content-type';
  static const requestHeaderContentValue = 'application/json';
}

/// [RelayClient] is a standard host and client provider which used
/// to subscribe to event source, send messages and init [UhstHost]
/// and Client [UhstSocket]
class RelayClient implements UhstRelayClient {
  RelayClient({
    required this.relayUrl,
  }) : networkClient = NetworkClient();
  NetworkClient networkClient;
  final String relayUrl;

  @override
  Future<ClientConfiguration> initClient({required String hostId}) async {
    final qParams = <String, String>{
      'action': 'join',
      'hostId': hostId,
    };
    try {
      final response = ClientConfiguration.fromJson(
        await networkClient.post(url: relayUrl, queryParameters: qParams),
      );
      return response;
    } on Exception catch (e) {
      if (e is NetworkException) {
        if (e.responseCode == 400) {
          throw InvalidHostId(e.message);
        } else {
          throw RelayException(e.message);
        }
      } else {
        throw RelayUnreachable(e);
      }
    }
  }

  @override
  Future<HostConfiguration> initHost({String? hostId}) async {
    final qParams = <String, String>{'action': 'host'};
    if (hostId != null) {
      qParams['hostId'] = hostId;
    }
    try {
      final response = HostConfiguration.fromJson(
          await networkClient.post(url: relayUrl, queryParameters: qParams));
      return response;
    } on Exception catch (e) {
      if (e is NetworkException) {
        if (e.responseCode == 400) {
          throw HostIdAlreadyInUse(e.message);
        } else {
          throw RelayException(e.message);
        }
      } else {
        throw RelayUnreachable(e);
      }
    }
  }

  @override
  Future<void> sendMessage({
    required String token,
    required dynamic message,
    String? sendUrl,
  }) async {
    final hostUrl = sendUrl ?? relayUrl;
    final uri = Uri.parse('$hostUrl?token=$token');
    try {
      await http.post(
        uri,
        headers: <String, String>{
          _RelayClientConsts.requestHeaderContentName:
              _RelayClientConsts.requestHeaderContentValue,
        },
        body: message,
      );
    } on Exception catch (e) {
      if (e is NetworkException) {
        switch (e.responseCode) {
          case 400:
            throw InvalidClientOrHostId(e.message);
          case 401:
            throw InvalidToken(e.message);
          default:
            throw RelayUnreachable(e.message);
        }
      }
    }
  }

  @override
  void subscribeToMessages({
    required String token,
    required RelayReadyHandler onReady,
    required RelayExceptionHandler onException,
    required RelayMessageHandler onMessage,
    RelayEventHandler? onRelayEvent,
    String? receiveUrl,
  }) {
    final url = receiveUrl ?? relayUrl;
    final finalUrl = '$url?token=$token';
    bool resolved = false;
    void onNotResolved(VoidCallback callback) {
      if (resolved) return;
      callback();
      resolved = true;
    }

    final EventSource source = EventSource(finalUrl);
    source.onOpen.listen((event) {
      onNotResolved(
        () => onReady(stream: RelayStream(eventSource: source)),
      );
    });
    source.onError.listen((event) {
      onNotResolved(
        () => onException(exception: RelayException(event)),
      );
    });
    source.onMessage.listen((event) {
      final eventMessageMap = jsonDecode(event.data);
      final eventMessage = EventMessage.fromJson(eventMessageMap);
      onMessage(message: eventMessage.body);
    });
    if (onRelayEvent != null) {
      source.addEventListener(
        'relay_event',
        (evt) {
          final messageEvent = evt as MessageEvent;
          final relayEvent = RelayEvent.fromJson(messageEvent.data);
          onRelayEvent(message: relayEvent);
        },
      );
    }
  }
}
