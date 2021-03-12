// library uhst;

// import 'package:uhst/src/contracts/uhst_relay_client.dart';
// import 'package:uhst/src/contracts/uhst_socket.dart';

// import 'contracts/uhst_socket_provider.dart';
// import 'models/rtc_configuration.dart';
// import 'models/socket_params.dart';
// import 'web_rtc_socket.dart';

// export 'package:uhst/src/models/socket_params.dart';

// class WebRtcSocketProvider implements UhstSocketProvider {
//   /// Used when instantiating the WebRtc connection.
//   /// Most importantly allows specifying iceServers for NAT
//   /// traversal.
//   ///
//   late final RtcConfiguration rtcConfiguration;
//   WebRtcSocketProvider({RtcConfiguration? configuration}) {
//     rtcConfiguration = configuration ??
//         RtcConfiguration(iceServers: [
//           RtcIceServer(
//               urls: [
//                 "stun:stun.l.google.com:19302",
//                 "stun:global.stun.twilio.com:3478"
//               ],
//               // FIXME: by lb.dom.d.ts username must be inside RtcIceServer
//               // does it needs to be included there?
//               username: 'test')
//         ]);
//   }

//   @override
//   UhstSocket createUhstSocket(
//       {required UhstRelayClient relayClient,
//       ClientSocketParams? clientParams,
//       HostSocketParams? hostParams,
//       required bool debug}) {
//     return WebRtcSocket.create(
//         relayClient: relayClient,
//         debug: debug,
//         configuration: this.rtcConfiguration,
//         hostSocketParams: hostParams,
//         clientSocketParams: clientParams);
//   }
// }
