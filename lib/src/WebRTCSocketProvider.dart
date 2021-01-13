export import 'package:UHST/src/models/socket_params.dart';

import 'package:UHST/src/contracts/uhst_socket.dart';

import 'package:UHST/src/contracts/uhst_api_client.dart';

import 'contracts/uhst_socket_provider.dart';

class WebRTCSocketProvider implements UhstSocketProvider {
  /**
   * Used when instantiating the WebRTC connection.
   * Most importantly allows specifying iceServers for NAT
   * traversal.
   * */
  RTCConfiguration rtcConfiguration;
  WebRTCSocketProvider(RTCConfiguration? configuration) {
    // TODO: implement RTCConfiguration
    // http://web.mit.edu/dart-lang_v1.24.2/gen-dartdocs/dart-html/RtcPeerConnection/RtcPeerConnection.html
    // or use recreate web configuration
    rtcConfiguration = configuration ?? { iceServers: [{ urls: "stun:stun.l.google.com:19302" }, { urls: "stun:global.stun.twilio.com:3478" }] };
  }

  @override
  UhstSocket createUhstSocket({required UhstApiClient apiClient, ClientSocketParams? clientParams, HostSocketParams? hostParams, required bool debug}) {
    // TODO: implement createUhstSocket
    // new WebRTCSocket(apiClient, this.rtcConfiguration, params, debug);
    throw UnimplementedError();
  }
}