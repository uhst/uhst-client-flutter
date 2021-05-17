library uhst;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart';

import './network_client.dart';
import '../contracts/uhst_relay_client.dart';
import '../models/relay_stream.dart';
import '../models/client_configuration.dart';
import '../models/event_message.dart';
import '../models/host_configration.dart';
import '../utils/uhst_exceptions.dart';

class _Consts {
  static const requestHeaderContentName = 'Content-type';
  static const requestHeaderContentValue = 'application/json';
}

/// [RelayClient] is a standard host and client provider which used
/// to subscribe to event source, send messages and init [UhstHost]
/// and Client [UhstSocket]
class RelayClient implements UhstRelayClient {
  NetworkClient networkClient;
  final String relayUrl;
  RelayClient({required this.relayUrl}) : networkClient = new NetworkClient();

  @override
  Future<ClientConfiguration> initClient({required String hostId}) async {
    var uri = Uri.parse(this.relayUrl);
    var qParams = Map<String, String>();
    qParams['action'] = 'join';
    qParams['hostId'] = hostId;
    uri = uri.replace(queryParameters: qParams);
    try {
      var response = await this
          .networkClient
          .post(uri: uri, fromJson: ClientConfiguration.fromJson);
      return response;
    } catch (e) {
      if (e is NetworkError) {
        if (e.responseCode == 400) {
          throw new InvalidHostId(e.message);
        } else {
          throw new RelayError(e.message);
        }
      } else {
        print(e);
        throw new RelayUnreachable(e);
      }
    }
  }

  @override
  Future<HostConfiguration> initHost({String? hostId}) async {
    var uri = Uri.parse(this.relayUrl);
    var qParams = Map<String, String>();
    qParams['action'] = 'host';
    if (hostId != null) {
      qParams['hostId'] = hostId;
    }
    uri = uri.replace(queryParameters: qParams);
    try {
      var response = await this
          .networkClient
          .post(uri: uri, fromJson: HostConfiguration.fromJson);
      return response;
    } catch (e) {
      if (e is NetworkError) {
        if (e.responseCode == 400) {
          throw new HostIdAlreadyInUse(e.message);
        } else {
          throw new RelayError(e.message);
        }
      } else {
        print(e);
        throw new RelayUnreachable(e);
      }
    }
  }

  @override
  Future sendMessage(
      {required String token, required message, String? sendUrl}) async {
    var hostUrl = sendUrl ?? relayUrl;
    var uri = Uri.parse('$hostUrl?token=$token');
    var response;
    try {
      response = await http.post(uri,
          headers: <String, String>{
            _Consts.requestHeaderContentName: _Consts.requestHeaderContentValue,
          },
          body: message);
    } catch (error) {
      throw RelayUnreachable(error);
    }
    switch (response.statusCode) {
      case 200:
        return;
      case 400:
        throw InvalidClientOrHostId(response.body);
      case 401:
        throw new InvalidToken(token);
      default:
        throw RelayError(response.body);
    }
  }

  @override
  subscribeToMessages(
      {required String token,
      required RelayReadyHandler onReady,
      required RelayErrorHandler onError,
      required RelayMessageHandler onMessage,
      String? receiveUrl}) {
    var url = receiveUrl ?? this.relayUrl;
    var finalUrl = '$url?token=$token';
    var uri = Uri.parse(finalUrl);

    EventSource source = EventSource(finalUrl);
    source.onOpen.listen((event) {
      onReady(stream: new RelayStream(eventSource: source));
    });
    source.onError.listen((event) {
      onError(error: RelayError(event));
    });
    source.onMessage.listen((event) {
      var eventMessageMap = jsonDecode(event.data);
      var eventMessage = EventMessage.fromJson(eventMessageMap);
      onMessage(message: eventMessage.body);
    });
  }
}
