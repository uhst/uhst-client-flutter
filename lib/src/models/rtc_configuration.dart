// library uhst;

// import 'package:universal_html/html.dart';
// 

// class RtcConfiguration {
//   final RtcBundlePolicy? bundlePolicy;
//   final List<RtcCertificate>? certificates;
//   final int? iceCandidatePoolSize;
//   final List<RtcIceServer>? iceServers;
//   final RtcIceTransportPolicy? iceTransportPolicy;
//   final String? peerIdentity;
//   final RtcRtcpMuxPolicy? rtcpMuxPolicy;
//   RtcConfiguration({
//     this.bundlePolicy,
//     this.certificates,
//     this.iceCandidatePoolSize,
//     this.iceServers,
//     this.iceTransportPolicy,
//     this.peerIdentity,
//     this.rtcpMuxPolicy,
//   });
//   Map<String, dynamic> get toJson => {
//         'bundlePolicy': bundlePolicy?.chosenPolicy,
//         'certificates': certificates,
//         'iceCandidatePoolSize': iceCandidatePoolSize,
//         'iceServers': iceServers?.map((e) => e.toJson),
//         'iceTransportPolicy': iceTransportPolicy?.chosenPolicy,
//         'peerIdentity': peerIdentity,
//         'rtcpMuxPolicy': rtcpMuxPolicy?.chosenPolicy
//       };
// }

// class RtcIceServer {
//   final String? credentialString;
//   final RtcOAuthCredential? credentialOAuth;
//   final RtcIceCredentialType? credentialType;
//   final List<String> urls;
//   final String username;
//   RtcIceServer(
//       {required this.username,
//       required this.urls,
//       this.credentialOAuth,
//       this.credentialString,
//       this.credentialType});
//   Map<String, dynamic> get toJson => {
//         'credential': credentialString ?? credentialOAuth?.toJson ?? '',
//         'credentialType': credentialType?.chosenType,
//         'urls': urls,
//         'username': username
//       };
// }

// class RtcOAuthCredential {
//   final String accessToken;
//   final String macKey;
//   RtcOAuthCredential({required this.accessToken, required this.macKey});
//   Map<String, dynamic> get toJson =>
//       {'accessToken': accessToken, 'macKey': macKey};
// }

// class RtcBundlePolicy {
//   static const String balanced = 'balanced';
//   static const String maxbundle = 'max-bundle';
//   static const String maxcompat = 'max-compact';
//   final String chosenPolicy;
//   RtcBundlePolicy({required this.chosenPolicy});
// }

// class RtcIceCredentialType {
//   static const String oauth = 'oauth';
//   static const String password = 'password';
//   final String chosenType;
//   RtcIceCredentialType({required this.chosenType});
// }

// class RtcIceTransportPolicy {
//   static const String all = 'all';
//   static const String relay = 'relay';
//   final String chosenPolicy;
//   RtcIceTransportPolicy({required this.chosenPolicy});
// }

// class RtcRtcpMuxPolicy {
//   static const String negotiate = 'negotiate';
//   static const String require = 'require';
//   final String chosenPolicy;
//   RtcRtcpMuxPolicy({required this.chosenPolicy});
// }

// class RtcSessionDescriptionInit {
//   late final RtcSessionDescription? _rtcSessionDescription;
//   final String? sdp;
//   final RtcSdpType? type;
//   RtcSessionDescriptionInit({this.sdp, this.type, rtcSessionDescription})
//       : _rtcSessionDescription = rtcSessionDescription;

//   RtcSessionDescription get rtcSessionDescription =>
//       _rtcSessionDescription ?? RtcSessionDescription(toJson);
//   Map<String, dynamic> get toJson {
//     var rtcSessionDescription = _rtcSessionDescription;
//     if (rtcSessionDescription == null) {
//       return {'sdp': sdp, 'type': type?.chosenType};
//     } else {
//       return {
//         'sdp': rtcSessionDescription.sdp,
//         'type': rtcSessionDescription.type,
//       };
//     }
//   }
// }

// class RtcSdpType {
//   static const String answer = 'answer';
//   static const String offer = 'offer';
//   static const String pranswer = 'pranswer';
//   static const String rollback = 'rollback';
//   final String chosenType;
//   RtcSdpType({required this.chosenType});
// }
