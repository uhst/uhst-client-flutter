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
    final qParams = <String, String>{};
    qParams['action'] = 'join';
    qParams['hostId'] = hostId;
    try {
      final response = ClientConfiguration.fromJson(
          await networkClient.post(url: relayUrl, queryParameters: qParams));
      return response;
    } on Exception catch (e) {
      if (e is NetworkException) {
        if (e.responseCode == 400) {
          throw InvalidHostId(e.message);
        } else {
          throw RelayException(e.message);
        }
      } else {
        print(e);
        throw RelayUnreachable(e);
      }
    }
  }

  @override
  Future<HostConfiguration> initHost({String? hostId}) async {
    final qParams = <String, String>{};
    qParams['action'] = 'host';
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
    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: <String, String>{
          _RelayClientConsts.requestHeaderContentName:
              _RelayClientConsts.requestHeaderContentValue,
        },
        body: message,
      );
    } on Exception catch (exception) {
      throw RelayUnreachable(exception);
    }
    switch (response.statusCode) {
      case 200:
        return;
      case 400:
        throw InvalidClientOrHostId(response.body);
      case 401:
        throw InvalidToken(token);
      default:
        throw RelayException(response.body);
    }
  }

  @override
  void subscribeToMessages({
    required String token,
    required RelayReadyHandler onReady,
    required RelayExceptionHandler onException,
    required RelayMessageHandler onMessage,
    String? receiveUrl,
  }) {
    final url = receiveUrl ?? relayUrl;
    final finalUrl = '$url?token=$token';

    final EventSource source = EventSource(finalUrl);
    source.onOpen.listen((event) {
      onReady(stream: RelayStream(eventSource: source));
    });
    source.onError.listen((event) {
      onException(exception: RelayException(event));
    });
    source.onMessage.listen((event) {
      final eventMessageMap = jsonDecode(event.data);
      final eventMessage = EventMessage.fromJson(eventMessageMap);
      onMessage(message: eventMessage.body);
    });
  }
}
