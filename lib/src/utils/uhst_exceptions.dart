/// How to determine and use Exception or Error
/// https://stackoverflow.com/questions/17315945/error-vs-exception-in-dart

library uhst;

/// TODO: implement doc InvalidHostId
class InvalidHostId extends _ExceptionMessage {
  InvalidHostId([message])
      : super(exceptionName: 'InvalidHostId', message: message);
}

/// TODO: implement doc HostIdAlreadyInUse
class HostIdAlreadyInUse extends _ExceptionMessage {
  HostIdAlreadyInUse([message])
      : super(exceptionName: 'HostIdAlreadyInUse', message: message);
}

/// TODO: implement doc InvalidClientOrHostId
class InvalidClientOrHostId extends _ExceptionMessage {
  InvalidClientOrHostId([message])
      : super(exceptionName: 'InvalidClientOrHostId', message: message);
}

/// TODO: implement doc RelayUnreachable
class NetworkUnreachable extends _ExceptionMessage {
  NetworkUnreachable([message])
      : super(exceptionName: 'NetworkUnreachable', message: message);
}

/// TODO: implement doc RelayError
class NetworkError extends _ExceptionMessage {
  final int responseCode;

  NetworkError({required this.responseCode, message})
      : super(exceptionName: 'NetworkError', message: message);
}

/// TODO: implement doc RelayUnreachable
class RelayUnreachable extends _ExceptionMessage {
  RelayUnreachable([message])
      : super(exceptionName: 'RelayUnreachable', message: message);
}

/// TODO: implement doc RelayError
class RelayError extends _ExceptionMessage {
  RelayError([message]) : super(exceptionName: 'RelayError', message: message);
}

/// TODO: implement doc InvalidToken
class InvalidToken extends _ExceptionMessage {
  InvalidToken(String? token)
      : super(exceptionName: 'InvalidToken', message: token);
}

class _ExceptionMessage implements Exception {
  final dynamic message;
  final String exceptionName;
  _ExceptionMessage({this.message, required this.exceptionName});
  String toString() {
    Object? message = this.message;
    if (message == null) return exceptionName;
    return "$exceptionName exception: $message";
  }
}
