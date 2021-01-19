import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:UHST/src/contracts/uhst_socket_events.dart';
import 'package:UHST/src/models/socket_params.dart';

import 'contracts/uhst_api_client.dart';
import 'contracts/uhst_socket.dart';
import 'models/message.dart';
import 'models/rtc_configuration.dart';
import 'socket_helper.dart';

class WebRtcSocket implements UhstSocket {
  late final SocketHelper _h;

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

  WebRtcSocket(
      {required UhstApiClient apiClient,
      required RtcConfiguration configuration,
      HostSocketParams? hostSocketParams,
      ClientSocketParams? clientSocketParams,
      required bool debug})
      : _configuration = configuration {
    _h = SocketHelper(
      debug: debug,
      apiClient: apiClient,
    );

    _connection = _createConnection();

    if (hostSocketParams is HostSocketParams) {
      // will connect to client
      _h.token = hostSocketParams.token;
      _h.sendUrl = hostSocketParams.sendUrl;
    } else if (clientSocketParams is ClientSocketParams) {
      // will connect to host
      _initClient(hostId: clientSocketParams.hostId);
    } else {
      throw ArgumentError(
          "Socket Parameters Type is not provided or unsupported");
    }
  }

  void close() {
    _verifiedConnection.close();
  }

  Future<void> handleMessage({Message? message}) async {
    if (message == null) throw ArgumentError('Message is null');
    if (message.body?.type == "offer") {
      if (_h.debug) _h.emitDiagnostic(body: "Received offer: ${message.body}");
      await _initHost(description: message.body);
    } else if (message.body.type == "answer") {
      if (_h.debug) _h.emitDiagnostic(body: "Received answer: ${message.body}");
      _verifiedConnection.setRemoteDescription(message.body);
      _offerAccepted = true;
      _processIceCandidates();
    } else {
      if (_h.debug)
        _h.emitDiagnostic(body: "Received ICE Candidates: ${message.body}");
      _pendingCandidates.add(message.body);
      _processIceCandidates();
    }
  }

  RtcPeerConnection _createConnection() {
    var connection = RtcPeerConnection(_configuration.toJson);
    connection.onIceConnectionStateChange.listen((event) {
      _handleConnectionStateChange(event: event);
    });
    connection.onIceCandidate.listen((event) {
      _handleIceCandidate(event: event);
    });
    return connection;
  }

  void _configureDataChannel() {
    _verifiedDataChannel.onOpen.listen((event) {
      if (_h.debug) _h.emitDiagnostic(body: "Data channel opened.");
      if (_h.apiMessageStream != null) {
        if (_h.debug) _h.emitDiagnostic(body: "Closing API message stream.");
      }
      _h.emit(message: UhstSocketEventType.diagnostic, body: "open.");
    });
    _verifiedDataChannel.onClose.listen((event) {
      if (_h.debug) _h.emitDiagnostic(body: "Data channel closed.");
      _h.emit(message: UhstSocketEventType.close);
    });
    _verifiedDataChannel.onMessage.listen((event) {
      if (_h.debug)
        _h.emitDiagnostic(
            body: "Message received on data channel: ${event.data} ");
      _h.emit(message: UhstSocketEventType.message, body: event.data);
    });
  }

  void _handleConnectionStateChange({required Event event}) {
    switch (_verifiedConnection.iceConnectionState) {
      case "connected":
        // The connection has become fully connected
        if (_h.debug) _h.emitDiagnostic(body: "WebRtc connection established.");
        break;
      case "disconnected":
        if (_h.debug)
          _h.emitDiagnostic(body: "WebRtc connection disconnected.");
        break;
      case "failed":
        if (_h.debug) _h.emitDiagnostic(body: "WebRtc connection failed.");
        // One or more transports has terminated unexpectedly or in an error
        break;
      case "closed":
        if (_h.debug) _h.emitDiagnostic(body: "WebRtc connection closed.");
        // The connection has been closed
        break;
    }
  }

  void _handleIceCandidate({required RtcPeerConnectionIceEvent event}) async {
    if (event.candidate != null) {
      if (_h.debug)
        _h.emitDiagnostic(body: "Sending ICE candidate: ${event.candidate}");
      try {
        await _h.apiClient.sendMessage(
            token: _h.verifiedToken,
            message: event.candidate,
            sendUrl: _h.sendUrl);
      } catch (e) {
        if (_h.debug)
          _h.emitDiagnostic(body: "Failed sending ICE candidate: $e");
        _h.emitError(body: e);
      }
    } else {
      if (_h.debug) _h.emitDiagnostic(body: "ICE gathering completed.");
    }
  }

  Future _initHost({required RtcSessionDescription description}) async {
    _verifiedConnection.onDataChannel.listen((event) {
      if (_h.debug)
        _h.emitDiagnostic(body: "Received new data channel: ${event.channel}");
      _dataChannel = event.channel;
      _configureDataChannel();
    });
    await _verifiedConnection.setRemoteDescription(
        RtcSessionDescriptionInit(rtcSessionDescription: description).toJson);
    if (_h.debug)
      _h.emitDiagnostic(body: "Set remote description on host: $description");
    var answer = await _verifiedConnection.createAnswer();
    try {
      await _h.apiClient.sendMessage(
          token: _h.verifiedToken, message: answer, sendUrl: _h.sendUrl);
      if (_h.debug) _h.emitDiagnostic(body: "Host sent offer answer: $answer");
    } catch (e) {
      if (_h.debug)
        _h.emitDiagnostic(body: "Host failed responding to offer: $e");
      _h.emitError(body: e);
    }

    await _verifiedConnection.setLocalDescription(
        RtcSessionDescriptionInit(rtcSessionDescription: answer).toJson);
    if (_h.debug)
      _h.emitDiagnostic(body: "Local description set to offer answer on host.");
    _offerAccepted = true;
    _processIceCandidates();
  }

  Future _initClient({required String hostId}) async {
    try {
      _dataChannel = _verifiedConnection.createDataChannel("uhst");
      if (_h.debug) _h.emitDiagnostic(body: "Data channel created on client.");
      _configureDataChannel();
      var config = await _h.apiClient.initClient(hostId: hostId);
      if (_h.debug)
        _h.emitDiagnostic(body: "Client configuration received from server.");
      var token = config.clientToken;
      _h.token = token;
      _h.sendUrl = config.sendUrl;
      _h.apiMessageStream = await _h.apiClient.subscribeToMessages(
          token: _h.verifiedToken,
          handler: handleMessage,
          receiveUrl: config.receiveUrl);
      if (_h.debug)
        _h.emitDiagnostic(body: "Client subscribed to messages from server.");
      var offer = await _verifiedConnection.createOffer();

      try {
        await _h.apiClient
            .sendMessage(token: token, message: offer, sendUrl: _h.sendUrl);
        if (_h.debug)
          _h.emitDiagnostic(body: "Client offer sent to host: $offer");
      } catch (e) {
        if (_h.debug) _h.emitDiagnostic(body: "Client failed: $e");
        _h.emitError(body: e);
      }

      await _verifiedConnection.setLocalDescription(
          RtcSessionDescriptionInit(rtcSessionDescription: offer).toJson);
      if (_h.debug) _h.emitDiagnostic(body: "Local description set on client.");
    } catch (error) {
      if (_h.debug) _h.emitDiagnostic(body: "Client failed: $error");
      _h.emitError(body: error);
    }
  }

  void _processIceCandidates() {
    if (!_offerAccepted) return;
    if (_h.debug)
      _h.emitDiagnostic(
          body: "Offer accepted, processing cached ICE candidates.");
    while (_pendingCandidates.length > 0) {
      var candidate = _pendingCandidates.removeLast();
      if (candidate != null) {
        _verifiedConnection.addIceCandidate(candidate);
        if (_h.debug)
          _h.emitDiagnostic(body: "Added ICE candidate: $candidate");
      }
    }
  }
  // on(eventName: EventName, handler: SocketEventSet[EventName]) {
  //     // _eventStream.on(eventName, handler);
  // }

  // once(eventName: EventName, handler: SocketEventSet[EventName]) {
  //     // _eventStream.once(eventName, handler);
  // }

  // off(eventName: EventName, handler: SocketEventSet[EventName]) {
  //     // _eventStream.off(eventName, handler);
  // }

  // // TODO: implement for on, off, once methods
  // _h.eventStream.listen((event) {
  //   if (event.containsKey(UhstSocketEventType.close)) {
  //   } else if (event.containsKey(UhstSocketEventType.diagnostic)) {
  //   } else if (event.containsKey(UhstSocketEventType.error)) {
  //   } else if (event.containsKey(UhstSocketEventType.message)) {
  //   } else if (event.containsKey(UhstSocketEventType.open)) {}
  // }, onDone: () {}, onError: () {});
  @override
  void offClose({required handler}) {
    _h.errorListenerHandlers.remove(handler);
  }

  @override
  void offDiagnostic({required handler}) {
    _h.diagntosticListenerHandlers.remove(handler);
  }

  @override
  void offError({required handler}) {
    _h.errorListenerHandlers.remove(handler);
  }

  @override
  void offMessage({required handler}) {
    _h.messageListenerHandlers.remove(handler);
  }

  @override
  void offOpen({required handler}) {
    _h.openListenerHandlers.remove(handler);
  }

  @override
  void onClose({required handler}) {
    _h.closeListenerHandlers.add(handler);
    var subsription = _h.eventStream.listen((event) {});
    subsription.onData((data) {
      if (data.containsKey(UhstSocketEventType.close)) {
        handler();
      }
    });
  }

  @override
  void onDiagnostic({required handler}) {
    _h.diagntosticListenerHandlers.add(handler);
    var subsription = _h.eventStream.listen((event) {});
    subsription.onData((data) {
      if (data.containsKey(UhstSocketEventType.diagnostic)) {
        handler(message: data.values.first);
      }
    });
  }

  @override
  void onError({required handler}) {
    _h.errorListenerHandlers.add(handler);
    var subsription = _h.eventStream.listen((event) {});
    subsription.onData((data) {
      if (data.containsKey(UhstSocketEventType.error)) {
        handler(error: data.values.first);
      }
    });
  }

  @override
  void onMessage({required handler}) {
    _h.messageListenerHandlers.add(handler);
    _h.eventStream.listen((event) {
      if (event.containsKey(UhstSocketEventType.message)) {
        handler(data: event.values.first);
      }
    });
  }

  @override
  void onOpen({required handler}) {
    _h.openListenerHandlers.add(handler);
    _h.eventStream.listen((event) {
      if (event.containsKey(UhstSocketEventType.open)) {
        handler(data: event.values.first);
      }
    });
  }

  @override
  void onceClose({required handler}) {
    // TODO: implement onceClose
  }

  @override
  void onceDiagnostic({required handler}) {
    // TODO: implement onceDiagnostic
  }

  @override
  void onceError({required handler}) {
    // TODO: implement onceError
  }

  @override
  void onceMessage({required handler}) {
    // TODO: implement onceMessage
  }

  @override
  void onceOpen({required handler}) {
    // TODO: implement onceOpen
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
    if (_h.debug)
      _h.emitDiagnostic(body: "Sent message on data channel: $message");
    _verifiedDataChannel.send(message);
  }
}
