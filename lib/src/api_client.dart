library uhst;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart';

import 'contracts/uhst_api_client.dart';
import 'models/client_configuration.dart';
import 'models/host_configration.dart';
import 'models/message.dart';
import 'uhst_errors.dart';
import 'uhst_exceptions.dart';

class _Consts {
  static const requestHeaderContentName = 'Content-type';
  static const requestHeaderContentValue = 'application/json';
}

typedef T FromJson<T>(Map<String, dynamic> map);

class ApiClient implements UhstApiClient {
  final String apiUrl;
  ApiClient({required this.apiUrl});

  Future<T> _fetch<T>(
      {required String url,
      String? hostId,
      required FromJson<T> fromJson}) async {
    T handleResponse({required http.Response response}) {
      switch (response.statusCode) {
        case 200:
          var responseText = response.body;
          if (responseText.isEmpty)
            throw ArgumentError('response text is empty');
          print(responseText);
          var decodedBody = jsonDecode(responseText);
          var configuration = fromJson(decodedBody);
          return configuration;
        case 400:
          throw InvalidHostId((hostId), argName: response.reasonPhrase);
        default:
          throw ApiError(response.request?.url);
      }
    }

    var uri = Uri.parse(url);
    try {
      var response = await http.post(uri, headers: <String, String>{
        _Consts.requestHeaderContentName: _Consts.requestHeaderContentValue,
      });
      return handleResponse(response: response);
    } catch (error) {
      throw ApiUnreachable(Uri(userInfo: error.toString()));
    }
  }

  @override
  Future<ClientConfiguration> initClient({required String hostId}) async {
    print('joining');
    var url = '$apiUrl?action=join&hostId=$hostId';
    var response = await _fetch(
        fromJson: ClientConfiguration.fromJson, hostId: (hostId), url: url);
    return response;
  }

  @override
  Future<HostConfiguration> initHost({String? hostId}) async {
    print('hosting');
    var url = '${this.apiUrl}?action=host&hostId=$hostId';
    print(url);
    var response = await _fetch(
        fromJson: HostConfiguration.fromJson, hostId: hostId, url: url);
    return response;
  }

  @override
  Future sendMessage(
      {required String token, required message, String? sendUrl}) async {
    dynamic handleResponse({required http.Response response}) {
      print({'readyState': response.statusCode});
      switch (response.statusCode) {
        case 200:
          var responseText = response.body;
          if (responseText.isEmpty)
            throw ArgumentError('response text is empty');
          var responseData = jsonDecode(responseText);
          return responseData;
        case 400:
          throw InvalidClientOrHostId(
            response.request?.url,
          );
        case 401:
          throw new InvalidToken(response.reasonPhrase);
        default:
          throw ApiError(response.request?.url);
      }
    }

    try {
      var hostUrl = sendUrl ?? apiUrl;
      var uri = Uri.parse('$hostUrl?token=$token');
      try {
        var response = await http.post(uri,
            headers: <String, String>{
              _Consts.requestHeaderContentName:
                  _Consts.requestHeaderContentValue,
            },
            body: message);
        return handleResponse(response: response);
      } catch (error) {
        throw ApiUnreachable(Uri(userInfo: error.toString()));
      }
    } catch (error) {
      throw ApiUnreachable(Uri(userInfo: error.toString()));
    }
  }

  @override
  Future<MessageStream> subscribeToMessages(
      {required String token, required handler, String? receiveUrl}) {
    var url = receiveUrl ?? this.apiUrl;
    var finalUrl = '$url?token=$token';
    var uri = Uri.parse(finalUrl);
    return Future.microtask(() {
      EventSource stream = EventSource(finalUrl);
      var onOpenSubcription = stream.onOpen.listen((event) {});
      var onErrorSubcription = stream.onError.listen((event) {
        throw ApiError(uri);
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
