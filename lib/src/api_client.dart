library UHST;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'contracts/uhst_api_client.dart';
import 'models/client_configuration.dart';
import 'models/host_configration.dart';
import 'models/message.dart';
import 'uhst_errors.dart';
import 'uhst_exceptions.dart';

class _Consts {
  static const requestMethod = 'POST';
  static const requestHeaderContentName = 'Content-type';
  static const requestHeaderContentValue = 'application/json';
}

typedef T fromJson<T>(Map<String, String> map);

class ApiClient implements UhstApiClient {
  final String apiUrl;
  ApiClient({required this.apiUrl});

  Future<T> _fetch<T>(
      {required String url,
      required int hostId,
      required fromJson<T> fromJson}) async {
    T requestComplete(HttpRequest request) {
      switch (request.status) {
        case 200:
          var responseText = request.responseText;
          if (responseText == null)
            throw ArgumentError('response text is empty');
          var response = jsonDecode(responseText);
          var configuration = fromJson(response);
          return configuration;
        case 400:
          throw InvalidHostId((hostId), argName: request.response.statusText);
        default:
          throw ApiError(
              uri: Uri(
                  port: hostId,
                  host: request.responseUrl,
                  userInfo:
                      '${request.response.status} ${request.response.statusText}'));
      }
    }

    StreamSubscription<ProgressEvent>? streamSubscription;
    var httpRequest = HttpRequest();

    try {
      var url = '${apiUrl}?action=join&hostId=${hostId}';
      httpRequest
        ..setRequestHeader(
            _Consts.requestHeaderContentName, _Consts.requestHeaderContentValue)
        ..open(_Consts.requestMethod, url);
      streamSubscription = httpRequest.onLoadEnd.listen((event) {});
      httpRequest.send('');
    } catch (error) {
      throw ApiUnreachable(uri: Uri(userInfo: error.toString()));
    }
    return Future.any([
      streamSubscription.asFuture((() {
        return requestComplete(httpRequest);
      })())
    ]);
  }

  @override
  Future<ClientConfiguration> initClient({required String hostId}) async {
    var url = '${apiUrl}?action=join&hostId=${hostId}';
    var response = await _fetch(
        fromJson: ClientConfiguration.fromJson,
        hostId: int.parse(hostId),
        url: url);
    return response;
  }

  @override
  Future<HostConfiguration> initHost({required String hostId}) async {
    var url = '${this.apiUrl}?action=host&hostId=${hostId}';
    var response = await _fetch(
        fromJson: HostConfiguration.fromJson,
        hostId: int.parse(hostId),
        url: url);
    return response;
  }

  @override
  Future sendMessage(
      {required String token, required message, String? sendUrl}) {
    dynamic requestComplete(HttpRequest request) {
      switch (request.status) {
        case 200:
          var responseText = request.responseText;
          if (responseText == null)
            throw ArgumentError('response text is empty');
          var responseData = jsonDecode(responseText);
          return responseData;
        case 400:
          throw InvalidClientOrHostId(
            request.responseUrl,
          );
        case 401:
          var response = request.response;

          throw new InvalidToken(response.statusText);
        default:
          var response = request.response;

          throw ApiError(
              uri: Uri(
                  host: request.responseUrl,
                  userInfo: '${response.status} ${response.statusText}'));
      }
    }

    StreamSubscription<ProgressEvent>? streamSubscription;
    var httpRequest = HttpRequest();

    try {
      var hostUrl = sendUrl ?? apiUrl;
      var url = '$hostUrl?token=$token';
      httpRequest
        ..setRequestHeader(
            _Consts.requestHeaderContentName, _Consts.requestHeaderContentValue)
        ..open(_Consts.requestMethod, url);
      streamSubscription = httpRequest.onLoadEnd.listen((event) {});
      httpRequest.send(message);
    } catch (error) {
      throw ApiUnreachable(uri: Uri(userInfo: error.toString()));
    }
    return Future.any([
      streamSubscription.asFuture((() {
        return requestComplete(httpRequest);
      })())
    ]);
  }

  @override
  Future<MessageStream> subscribeToMessages(
      {required String token, required handler, String? receiveUrl}) {
    var url = receiveUrl ?? this.apiUrl;
    var finalUrl = '$url?token=$token';
    var uri = Uri.http(finalUrl, '');
    return Future.microtask(() {
      EventSource stream = EventSource(finalUrl);
      var onOpenSubcription = stream.onOpen.listen((event) {});
      var onErrorSubcription = stream.onError.listen((event) {
        throw ApiError(uri: uri);
      });
      var onMessageSubcription = stream.onMessage.listen((event) {
        Message message = Message.fromJson(jsonDecode(event.data));
        handler(message: message);
      });

      return Future.any([
        onMessageSubcription.asFuture(),
        onOpenSubcription.asFuture(),
        onErrorSubcription.asFuture()
      ]);
    });
  }
}
