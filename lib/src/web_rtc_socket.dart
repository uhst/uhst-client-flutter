library uhst;

import 'dart:async';
// import 'dart:html';
import 'dart:typed_data';

import 'package:uhst/src/contracts/uhst_socket_events.dart';
import 'package:uhst/src/models/socket_params.dart';
import 'package:uhst/src/socket_subsriptions.dart';
import 'package:universal_html/html.dart';

import 'contracts/uhst_api_client.dart';
import 'contracts/uhst_socket.dart';
import 'models/message.dart';
import 'models/rtc_configuration.dart';
import 'socket_helper.dart';

class WebRtcSocket with SocketSubsriptions implements UhstSocket {
  final List<RtcIceCandidate?> _pendingCandidates = [];

  bool _offerAccepted = false;

  RtcPeerConnection? _connection;
  RtcPeerConnection get _verifiedConnection {
    var connection = _connection;
    if (connection == null) throw ArgumentError('Connection is null!');
    return connection;
  }

  RtcDataChannel? _dataChannel;
  RtcDataChannel get _verifiedDataChannel {
    var dataChannel = _dataChannel;
    if (dataChannel == null) throw ArgumentError('DataChannel is null!');
    return dataChannel;
  }

  final RtcConfiguration _configuration;

  WebRtcSocket._create(
      {required UhstApiClient apiClient,
      required RtcConfiguration configuration,
      required bool debug})
      : _configuration = configuration {
    h = SocketHelper(
      debug: debug,
      apiClient: apiClient,
    );

    _connection = _createConnection();
  }

  static Future<WebRtcSocket> create(
      {required UhstApiClient apiClient,
      required RtcConfiguration configuration,
      HostSocketParams? hostSocketParams,
      ClientSocketParams? clientSocketParams,
      required bool debug}) async {
    var socket = WebRtcSocket._create(
        apiClient: apiClient, configuration: configuration, debug: debug);
    if (hostSocketParams is HostSocketParams) {
      // will connect to client
      socket.h.token = hostSocketParams.token;
      socket.h.sendUrl = hostSocketParams.sendUrl;
    } else if (clientSocketParams is ClientSocketParams) {
      // will connect to host
      await socket._initClient(hostId: clientSocketParams.hostId);
    } else {
      throw ArgumentError(
          "Socket Parameters Type is not provided or unsupported");
    }
    return socket;
  }

  void close() {
    _verifiedConnection.close();
  }

  Future<void> handleMessage({Message? message}) async {
    if (message == null) throw ArgumentError('Message is null');
    var body = message.body;
    if (body == null) throw ArgumentError('Message body is null');
    if (message.type == "offer") {
      if (h.debug) h.emitDiagnostic(body: "Received offer: $body");
      await _initHost(description: RtcSessionDescription(body));
    } else if (message.type == "answer") {
      if (h.debug) h.emitDiagnostic(body: "Received answer: $body");
      _verifiedConnection.setRemoteDescription(body);
      _offerAccepted = true;
      _processIceCandidates();
    } else {
      if (h.debug)
        h.emitDiagnostic(body: "Received ICE Candidates: ${message.body}");
      _pendingCandidates.add(RtcIceCandidate(body));
      _processIceCandidates();
    }
  }

  RtcPeerConnection _createConnection() {
    var connection = RtcPeerConnection(_configuration.toJson);
    connection.onIceConnectionStateChange.listen((event) {
      handleConnectionStateChange(event: event);
    });
    connection.onIceCandidate.listen((event) {
      handleIceCandidate(event: event);
    });
    return connection;
  }

  void _configureDataChannel() {
    _verifiedDataChannel.onOpen.listen((event) {
      if (h.debug) h.emitDiagnostic(body: "Data channel opened.");
      if (h.apiMessageStream != null) {
        if (h.debug) h.emitDiagnostic(body: "Closing API message stream.");
      }
      h.emit(message: UhstSocketEventType.diagnostic, body: "open.");
    });
    _verifiedDataChannel.onClose.listen((event) {
      if (h.debug) h.emitDiagnostic(body: "Data channel closed.");
      h.emit(message: UhstSocketEventType.close);
    });
    _verifiedDataChannel.onMessage.listen((event) {
      if (h.debug)
        h.emitDiagnostic(
            body: "Message received on data channel: ${event.data} ");
      h.emit(message: UhstSocketEventType.message, body: event.data);
    });
  }

  void handleConnectionStateChange({required Event event}) {
    switch (_verifiedConnection.iceConnectionState) {
      case "connected":
        // The connection has become fully connected
        if (h.debug) h.emitDiagnostic(body: "WebRtc connection established.");
        break;
      case "disconnected":
        if (h.debug) h.emitDiagnostic(body: "WebRtc connection disconnected.");
        break;
      case "failed":
        if (h.debug) h.emitDiagnostic(body: "WebRtc connection failed.");
        // One or more transports has terminated unexpectedly or in an error
        break;
      case "closed":
        if (h.debug) h.emitDiagnostic(body: "WebRtc connection closed.");
        // The connection has been closed
        break;
    }
  }

  void handleIceCandidate({required RtcPeerConnectionIceEvent event}) async {
    if (event.candidate != null) {
      if (h.debug)
        h.emitDiagnostic(body: "Sending ICE candidate: ${event.candidate}");
      try {
        await h.apiClient.sendMessage(
            token: h.verifiedToken,
            message: event.candidate,
            sendUrl: h.sendUrl);
      } catch (e) {
        if (h.debug) h.emitDiagnostic(body: "Failed sending ICE candidate: $e");
        h.emitError(body: e);
      }
    } else {
      if (h.debug) h.emitDiagnostic(body: "ICE gathering completed.");
    }
  }

  Future _initHost({required RtcSessionDescription description}) async {
    _verifiedConnection.onDataChannel.listen((event) {
      if (h.debug)
        h.emitDiagnostic(body: "Received new data channel: ${event.channel}");
      _dataChannel = event.channel;
      _configureDataChannel();
    });
    await _verifiedConnection.setRemoteDescription(
        RtcSessionDescriptionInit(rtcSessionDescription: description).toJson);
    if (h.debug)
      h.emitDiagnostic(body: "Set remote description on host: $description");
    var answer = await _verifiedConnection.createAnswer();
    try {
      await h.apiClient.sendMessage(
          token: h.verifiedToken, message: answer, sendUrl: h.sendUrl);
      if (h.debug) h.emitDiagnostic(body: "Host sent offer answer: $answer");
    } catch (e) {
      if (h.debug)
        h.emitDiagnostic(body: "Host failed responding to offer: $e");
      h.emitError(body: e);
    }

    await _verifiedConnection.setLocalDescription(
        RtcSessionDescriptionInit(rtcSessionDescription: answer).toJson);
    if (h.debug)
      h.emitDiagnostic(body: "Local description set to offer answer on host.");
    _offerAccepted = true;
    _processIceCandidates();
  }

  Future _initClient({required String hostId}) async {
    try {
      _dataChannel = _verifiedConnection.createDataChannel("uhst");
      if (h.debug) h.emitDiagnostic(body: "Data channel created on client.");
      _configureDataChannel();
      var config = await h.apiClient.initClient(hostId: hostId);
      if (h.debug)
        h.emitDiagnostic(body: "Client configuration received from server.");
      var token = config.clientToken;
      h.token = token;
      h.sendUrl = config.sendUrl;
      h.apiMessageStream = await h.apiClient.subscribeToMessages(
          token: h.verifiedToken,
          handler: handleMessage,
          receiveUrl: config.receiveUrl);
      if (h.debug)
        h.emitDiagnostic(body: "Client subscribed to messages from server.");
      var offer = await _verifiedConnection.createOffer();

      try {
        await h.apiClient
            .sendMessage(token: token, message: offer, sendUrl: h.sendUrl);
        if (h.debug)
          h.emitDiagnostic(body: "Client offer sent to host: $offer");
      } catch (e) {
        if (h.debug) h.emitDiagnostic(body: "Client failed: $e");
        h.emitError(body: e);
      }

      await _verifiedConnection.setLocalDescription(
          RtcSessionDescriptionInit(rtcSessionDescription: offer).toJson);
      if (h.debug) h.emitDiagnostic(body: "Local description set on client.");
    } catch (error) {
      if (h.debug) h.emitDiagnostic(body: "Client failed: $error");
      h.emitError(body: error);
    }
  }

  void _processIceCandidates() {
    if (!_offerAccepted) return;
    if (h.debug)
      h.emitDiagnostic(
          body: "Offer accepted, processing cached ICE candidates.");
    while (_pendingCandidates.length > 0) {
      var candidate = _pendingCandidates.removeLast();
      if (candidate != null) {
        _verifiedConnection.addIceCandidate(candidate);
        if (h.debug) h.emitDiagnostic(body: "Added ICE candidate: $candidate");
      }
    }
  }

  @override
  @Deprecated("Use sendByteBufer instead")
  void sendArrayBuffer({required ByteBuffer arrayBuffer}) {
    sendByteBufer(byteBuffer: arrayBuffer);
  }

  @override
  @Deprecated("Use sendTypedData instead")
  void sendArrayBufferView({required TypedData arrayBufferView}) {
    sendTypedData(typedData: arrayBufferView);
  }

  @override
  void sendBlob({required Blob blob}) {
    _send(message: blob);
  }

  @override
  void sendByteBufer({required ByteBuffer byteBuffer}) {
    _send(message: byteBuffer);
  }

  @override
  void sendString({required String message}) {
    _send(message: message);
  }

  @override
  void sendTypedData({required TypedData typedData}) {
    _send(message: typedData);
  }

  void _send({dynamic? message}) {
    if (h.debug)
      h.emitDiagnostic(body: "Sent message on data channel: $message");
    _verifiedDataChannel.send(message);
  }
}
