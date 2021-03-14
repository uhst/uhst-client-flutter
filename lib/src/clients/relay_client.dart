library uhst;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uhst/src/models/event_message.dart';
import 'package:universal_html/html.dart';

import '../contracts/type_definitions.dart';
import '../contracts/uhst_relay_client.dart';
import '../models/client_configuration.dart';
import '../models/host_configration.dart';
import '../utils/uhst_errors.dart';
import '../utils/uhst_exceptions.dart';
import './network_client.dart';

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

  /// Returns generic [T] type from response
  /// Handles error cases
  Future<T> _fetch<T>(
      {required String url,
      String? hostId,
      required FromJson<T> fromJson}) async {
    T handleResponseForFetch({required http.Response response}) {
      switch (response.statusCode) {
        case 200:
          var responseText = response.body;
          if (responseText.isEmpty)
            throw ArgumentError('response text is empty');
          var decodedBody = jsonDecode(responseText);
          var configuration = fromJson(decodedBody);
          return configuration;
        case 400:
          throw InvalidHostId((hostId), argName: response.reasonPhrase);
        default:
          throw RelayError(response.request?.url);
      }
    }

    var uri = Uri.parse(url);
    try {
      var response = await http.post(uri, headers: <String, String>{
        _Consts.requestHeaderContentName: _Consts.requestHeaderContentValue,
      });
      return handleResponseForFetch(response: response);
    } catch (error) {
      throw RelayUnreachable(Uri(userInfo: error.toString()));
    }
  }

  @override
  Future<ClientConfiguration> initClient({required String hostId}) async {
    var url = '$relayUrl?action=join&hostId=$hostId';
    var response = await _fetch(
        fromJson: ClientConfiguration.fromJson, hostId: (hostId), url: url);
    return response;
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
    var response = await this
        .networkClient
        .post(uri: uri, fromJson: HostConfiguration.fromJson);
    return response;
  }

  @override
  Future sendMessage(
      {required String token, required message, String? sendUrl}) async {
    dynamic handleResponseForMessage({required http.Response response}) {
      switch (response.statusCode) {
        case 200:
          var responseText = response.body;
          if (responseText.isEmpty)
            throw ArgumentError('response text is empty');
          // In case if all is ok, then ok
          if (responseText.toLowerCase() == 'ok') return 'OK';

          var responseData = jsonDecode(responseText);
          return responseData;
        case 400:
          throw InvalidClientOrHostId(
            response.request?.url,
          );
        case 401:
          throw new InvalidToken(response.reasonPhrase);
        default:
          throw RelayError(response.request?.url);
      }
    }

    var hostUrl = sendUrl ?? relayUrl;
    var uri = Uri.parse('$hostUrl?token=$token');

    try {
      var response = await http.post(uri,
          headers: <String, String>{
            _Consts.requestHeaderContentName: _Consts.requestHeaderContentValue,
          },
          body: message);
      return handleResponseForMessage(response: response);
    } catch (error) {
      throw RelayUnreachable(uri);
    }
  }

  @override
  Future<EventSource> subscribeToMessages(
      {required String token, required handler, String? receiveUrl}) {
    var url = receiveUrl ?? this.relayUrl;
    var finalUrl = '$url?token=$token';
    var uri = Uri.parse(finalUrl);
    var completer = Completer<EventSource>();

    EventSource source = EventSource(finalUrl);
    source.onOpen.listen((event) {
      completer.complete(source);
    });
    source.onError.listen((event) {
      completer.completeError(RelayError(uri));
    });
    source.onMessage.listen((event) {
      var eventMessageMap = jsonDecode(event.data);
      var eventMessage = EventMessage.fromJson(eventMessageMap);
      handler(message: eventMessage.body);
    });
    return completer.future;
  }
}
