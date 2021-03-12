/// How to determine and use Exception or Error
/// https://stackoverflow.com/questions/17315945/error-vs-exception-in-dart

library uhst;

/// TODO: implement doc HostIdAlreadyInUse
class HostIdAlreadyInUse extends _ExceptionMessage {
  HostIdAlreadyInUse([int? hostId])
      : super(exceptionName: 'HostIdAlreadyInUse', message: hostId);
}

/// TODO: implement doc RelayUnreachable
class NetworkUnreachable extends _ExceptionMessage {
  NetworkUnreachable([Uri? message])
      : super(exceptionName: 'NetworkUnreachable', message: message);
}

/// TODO: implement doc RelayError
class NetworkError extends _ExceptionMessage {
  NetworkError([String? message])
      : super(exceptionName: 'NetworkError', message: message);
}

/// TODO: implement doc RelayUnreachable
class RelayUnreachable extends _ExceptionMessage {
  RelayUnreachable([Uri? message])
      : super(exceptionName: 'RelayUnreachable', message: message);
}

/// TODO: implement doc RelayError
class RelayError extends _ExceptionMessage {
  RelayError([Uri? message])
      : super(exceptionName: 'RelayError', message: message);
}

class _ExceptionMessage implements Exception {
  final dynamic message;
  final String exceptionName;
  _ExceptionMessage({this.message, required this.exceptionName});
  String toString() {
    Object? message = this.message;
    if (message == null) return "Exception";
    return "$exceptionName exception: $message";
  }
}
