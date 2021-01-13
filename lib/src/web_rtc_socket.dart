import 'dart:html';
import 'dart:typed_data';

import 'package:UHST/src/contracts/uhst_socket_events.dart';
import 'package:UHST/src/models/socket_params.dart';

import 'contracts/uhst_api_client.dart';
import 'contracts/uhst_socket.dart';
import 'models/message.dart';

class WebRTCSocket implements UhstSocket {
//  FIXME: implement socket and make final
  late final Stream<UhstSocketEventType>? _ee;
  // RTCIceCandidate | RTCIceCandidateInit
  final _pendingCandidates = [];

  bool _offerAccepted = false;
  late final String? _token;
  RTCPeerConnection? _connection;
  RTCDataChannel? _dataChannel;
  MessageStream? _apiMessageStream;
  final RTCConfiguration _configuration;
  String? _sendUrl;
  final bool _debug;
  final UhstApiClient _apiClient;
  WebRTCSocket(
      {required UhstApiClient apiClient,
      required RTCConfiguration configuration,
      HostSocketParams? hostSocketParams,
      ClientSocketParams? clientSocketParams,
      required bool debug})
      : _debug = debug,
        _configuration = configuration,
        _apiClient = apiClient {
    _connection = _createConnection();
    if (hostSocketParams is HostSocketParams) {
      // will connect to client
      _token = hostSocketParams.token;
      _sendUrl = hostSocketParams.sendUrl;
    } else if (clientSocketParams is ClientSocketParams) {
      // will connect to host
      _initClient(hostId: clientSocketParams.hostId);
    } else {
      throw ArgumentError(
          "Socket Parameters Type is not provided or unsupported");
    }
  }

  // on<EventName extends keyof SocketEventSet>(eventName: EventName, handler: SocketEventSet[EventName]) {
  //     // _ee.on(eventName, handler);
  // }

  // once<EventName extends keyof SocketEventSet>(eventName: EventName, handler: SocketEventSet[EventName]) {
  //     // _ee.once(eventName, handler);
  // }

  // off<EventName extends keyof SocketEventSet>(eventName: EventName, handler: SocketEventSet[EventName]) {
  //     // _ee.off(eventName, handler);
  // }

  void close() {
    _connection.close();
  }

  void handleMessage({Message? message}) {
    if (message == null) throw Error('Message is null');
    if (message.body?.type == "offer") {
      if (_debug) _ee.emit("diagnostic", "Received offer: ${message.body}");
      _initHost(description: message.body);
    } else if (message.body.type == "answer") {
      if (_debug) _ee.emit("diagnostic", "Received answer:  ${message.body}");
      _connection.setRemoteDescription(message.body);
      _offerAccepted = true;
      _processIceCandidates();
    } else {
      if (_debug)
        _ee.emit("diagnostic", "Received ICE Candidates: ${message.body}");
      _pendingCandidates.push(message.body);
      _processIceCandidates();
    }
  }

  RTCPeerConnection _createConnection() {
    var connection = RTCPeerConnection(_configuration);
    connection.onconnectionstatechange = _handleConnectionStateChange;
    connection.onicecandidate = _handleIceCandidate;
    return connection;
  }

  void _configureDataChannel() {
    _dataChannel.onopen = () {
      if (_debug) _ee.emit("diagnostic", "Data channel opened.");
      if (_apiMessageStream != null) {
        if (_debug) _ee.emit("diagnostic", "Closing API message stream.");
        _apiMessageStream.close();
      }
      _ee.emit("open");
    };
    _dataChannel.onclose = () {
      if (_debug) _ee.emit("diagnostic", "Data channel closed.");
      _ee.emit("close");
    };
    _dataChannel.onmessage = (dynamic? event) {
      if (_debug)
        _ee.emit(
            "diagnostic", "Message received on data channel: " + event?.data);
      _ee.emit("message", event?.data);
    };
  }

  void _handleConnectionStateChange({required Event event}) {
    switch (_connection.connectionState) {
      case "connected":
        // The connection has become fully connected
        if (_debug) _ee.emit("diagnostic", "WebRTC connection established.");
        break;
      case "disconnected":
        if (_debug) _ee.emit("diagnostic", "WebRTC connection disconnected.");
        break;
      case "failed":
        if (_debug) _ee.emit("diagnostic", "WebRTC connection failed.");
        // One or more transports has terminated unexpectedly or in an error
        break;
      case "closed":
        if (_debug) _ee.emit("diagnostic", "WebRTC connection closed.");
        // The connection has been closed
        break;
    }
  }

  void _handleIceCandidate({required RTCPeerConnectionIceEvent event}) async {
    if (event.candidate) {
      if (_debug)
        _ee.emit("diagnostic", "Sending ICE candidate: ${event.candidate}");
      try {
        await _apiClient.sendMessage(
            token: _token, message: event.candidate, sendUrl: _sendUrl);
      } catch (e) {
        if (_debug) _ee.emit("diagnostic", "Failed sending ICE candidate: $e");
        _ee.emit("error", e);
      }
    } else {
      if (_debug) _ee.emit("diagnostic", "ICE gathering completed.");
    }
  }

  Future _initHost({required RTCSessionDescriptionInit description}) async {
    _connection.ondatachannel = (event) {
      if (_debug)
        _ee.emit("diagnostic", "Received new data channel: ${event.channel}");
      _dataChannel = event.channel;
      _configureDataChannel();
    };
    await _connection.setRemoteDescription(description);
    if (_debug)
      _ee.emit("diagnostic", "Set remote description on host: $description");
    var answer = await _connection.createAnswer();
    try {
      await _apiClient.sendMessage(
          token: _token, message: answer, sendUrl: _sendUrl);
      if (_debug) _ee.emit("diagnostic", "Host sent offer answer: $answer");
    } catch (e) {
      if (_debug) _ee.emit("diagnostic", "Host failed responding to offer: $e");
      _ee.emit("error", error);
    }

    await _connection.setLocalDescription(answer);
    if (_debug)
      _ee.emit("diagnostic", "Local description set to offer answer on host.");
    _offerAccepted = true;
    _processIceCandidates();
  }

  Future _initClient({required String hostId}) async {
    try {
      _dataChannel = _connection.createDataChannel("uhst");
      if (_debug) _ee.emit("diagnostic", "Data channel created on client.");
      _configureDataChannel();
      var config = await _apiClient.initClient(hostId: hostId);
      if (_debug)
        _ee.emit("diagnostic", "Client configuration received from server.");
      _token = config.clientToken;
      _sendUrl = config.sendUrl;
      _apiMessageStream = await _apiClient.subscribeToMessages(
          token: config.clientToken,
          handler: handleMessage,
          receiveUrl: config.receiveUrl);
      if (_debug)
        _ee.emit("diagnostic", "Client subscribed to messages from server.");
      var offer = await _connection.createOffer();

      try {
        await _apiClient.sendMessage(
            token: _token, message: offer, sendUrl: _sendUrl);
        if (_debug) _ee.emit("diagnostic", "Client offer sent to host: $offer");
      } catch (e) {
        if (_debug) _ee.emit("diagnostic", "Client failed: $e");
        _ee.emit("error", e);
      }

      await _connection.setLocalDescription(offer);
      if (_debug) _ee.emit("diagnostic", "Local description set on client.");
    } catch (error) {
      if (_debug) _ee.emit("diagnostic", "Client failed: $error");
      _ee.emit("error", error);
    }
  }

  _processIceCandidates() {
    if (!_offerAccepted) return;
    if (_debug)
      _ee.emit(
          "diagnostic", "Offer accepted, processing cached ICE candidates.");
    while (_pendingCandidates.length > 0) {
      var candidate = _pendingCandidates.pop();
      if (candidate) {
        _connection.addIceCandidate(candidate);
        if (_debug) _ee.emit("diagnostic", "Added ICE candidate: $candidate");
      }
    }
  }

  @override
  void offClose({required handler}) {
    // TODO: implement offClose
  }

  @override
  void offDiagnostic({required handler}) {
    // TODO: implement offDiagnostic
  }

  @override
  void offError({required handler}) {
    // TODO: implement offError
  }

  @override
  void offMessage({required handler}) {
    // TODO: implement offMessage
  }

  @override
  void offOpen({required handler}) {
    // TODO: implement offOpen
  }

  @override
  void onClose({required handler}) {
    // TODO: implement onClose
  }

  @override
  void onDiagnostic({required handler}) {
    // TODO: implement onDiagnostic
  }

  @override
  void onError({required handler}) {
    // TODO: implement onError
  }

  @override
  void onMessage({required handler}) {
    // TODO: implement onMessage
  }

  @override
  void onOpen({required handler}) {
    // TODO: implement onOpen
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
  void sendArrayBuffer({required ByteBuffer arrayBuffer}) {
    // TODO: implement sendArrayBuffer
  }

  @override
  void sendArrayBufferView({required TypedData arrayBufferView}) {
    // TODO: implement sendArrayBufferView
  }

  @override
  void sendBlob({required Blob blob}) {
    // TODO: implement sendBlob
  }

  @override
  void sendByteBufer({required ByteBuffer byteBuffer}) {
    // TODO: implement sendByteBufer
  }

  @override
  void sendString({required String message}) {
    // TODO: implement sendString
  }

  @override
  void sendTypedData({required TypedData typedData}) {
    // TODO: implement sendTypedData
  }

  // send(message: string): void;
  // send(message: Blob): void;
  // send(message: ArrayBuffer): void;
  // send(message: ArrayBufferView): void;

  void send({dynamic? message}) {
    if (_debug)
      _ee.emit("diagnostic", "Sent message on data channel: $message");
    _dataChannel.send(message);
  }
}
