import 'dart:convert';
import 'dart:html';

import 'contracts/uhst_api_client.dart';
import 'models/client_configuration.dart';
import 'models/host_configration.dart';
import 'uhst_errors.dart';
import 'uhst_exceptions.dart';

const REQUEST_OPTIONS = {
  'method': 'POST',
  'headers': {
    'Content-Type': 'application/json',
  }
};
const RequestMethod = 'POST';

class ApiClient implements UhstApiClient {
  final String apiUrl;
  ApiClient({required this.apiUrl});

  @override
  Future<ClientConfiguration> initClient({required String hostId})async {
        void requestComplete(HttpRequest request) {
          switch (request.status) {
            case 200:
            var responseText = request.responseText;
            if(responseText == null) throw ArgumentError('response text is empty');
           var response = jsonDecode(responseText);

          var configuration = ClientConfiguration.fromJson(response);
break;
            case 400:
              throw InvalidHostId(int.parse(hostId), argName: request.response.statusText);
            default:
              throw  ApiError(uri: Uri(port: int.parse(hostId),host: request.responseUrl, userInfo: '${request.response.status} ${request.response.statusText}'));
          }
        }

        try {
         var httpRequest= HttpRequest();
         var url = '${apiUrl}?action=join&hostId=${hostId}';
         httpRequest
         ..setRequestHeader('Content-Type', 'application/json')
         ..open(RequestMethod, url)
         ..onLoadEnd.listen((event) { 
            requestComplete(httpRequest);
         })
         ..send('');
        } catch (error) {
            throw ApiUnreachable(uri: Uri(userInfo: error.toString()));
        }
       
  }

  @override
  Future<HostConfiguration> initHost({required String hostId}) {
    let response: Response;
        try {
            response = await fetch(`${this.apiUrl}?action=host&hostId=${hostId}`, REQUEST_OPTIONS);
        } catch (error) {
            console.log(error);
            throw new ApiUnreachable(error);
        }
        if (response.status == 200) {
            const jsonResponse = await response.json();
            return jsonResponse;
        } else if (response.status == 400) {
            throw new HostIdAlreadyInUse(response.statusText);
        } else {
            throw new ApiError(`${response.status} ${response.statusText}`);
        }
  }

  @override
  Future sendMessage(
      {required String token, required message, String? sendUrl}) {
    const url = sendUrl ?? this.apiUrl;
        let response: Response;
        try {
            response = await fetch(`${url}?token=${token}`, {
                ...REQUEST_OPTIONS,
                body: JSON.stringify(message),
            });
        } catch (error) {
            console.log(error);
            throw new ApiUnreachable(error);
        }
        if (response.status == 200) {
            return;
        } else if (response.status == 400) {
            throw new InvalidClientOrHostId(response.statusText);
        } else if (response.status == 401) {
            throw new InvalidToken(response.statusText);
        } else {
            throw new ApiError(`${response.status} ${response.statusText}`);
        }
  }

  @override
  Future<MessageStream> subscribeToMessages(
      {required String token, required handler, String? receiveUrl}) {
     const url = receiveUrl ?? this.apiUrl;
        return new Promise<MessageStream>((resolve, reject) => {
            const stream = new EventSource(`${url}?token=${token}`);
            stream.onopen = (ev: Event) => {
                resolve(stream);
            };
            stream.onerror = (ev: Event) => {
                reject(new ApiError(ev));
            };
            stream.addEventListener("message", (evt: MessageEvent) => {
                const message: Message = JSON.parse(evt.data);
                handler(message);
            });
        });
  }
}
