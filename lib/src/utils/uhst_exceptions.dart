/// How to determine and use Exception or Error
/// https://stackoverflow.com/questions/17315945/error-vs-exception-in-dart
///
/// `Exceptions` should be used when there is a problem that is expected.
/// A common one is any type of I/O operation (like network traffic),
/// where the socket closes early, and trying to write data to
/// that socket fails.
/// `Errors` occur when there is a problem that was not expected.
/// Things like null pointers (you expected this variable to not be null),
/// running our of memory, etc... When you try to use the API in
/// a wrong way or stuffs like that.
/// `For the most part` you, as an app developer, will always `use exceptions`.
/// Errors tend to be reserved for unexpected and fatal problems.
part of uhst_utils;

class HostDisconnected extends _ExceptionMessage {
  /// This exception is used for Relay connection,
  /// when socket receives [RelayEventType.hostClosed] event
  HostDisconnected([message])
      : super(exceptionName: 'HostDisconnected', message: message);
}

class InvalidHostId extends _ExceptionMessage {
  InvalidHostId([message])
      : super(exceptionName: 'InvalidHostId', message: message);
}

class HostIdAlreadyInUse extends _ExceptionMessage {
  HostIdAlreadyInUse([message])
      : super(exceptionName: 'HostIdAlreadyInUse', message: message);
}

class InvalidClientOrHostId extends _ExceptionMessage {
  InvalidClientOrHostId([message])
      : super(exceptionName: 'InvalidClientOrHostId', message: message);
}

class NetworkUnreachable extends _ExceptionMessage {
  NetworkUnreachable([message])
      : super(exceptionName: 'NetworkUnreachable', message: message);
}

class NetworkException extends _ExceptionMessage {
  NetworkException({
    required this.responseCode,
    message,
  }) : super(exceptionName: 'NetworkException', message: message);
  final int responseCode;
}

class RelayUnreachable extends _ExceptionMessage {
  RelayUnreachable([message])
      : super(exceptionName: 'RelayUnreachable', message: message);
}

class RelayException extends _ExceptionMessage {
  RelayException([message])
      : super(exceptionName: 'RelayException', message: message);
}

class InvalidToken extends _ExceptionMessage {
  InvalidToken(String? token)
      : super(exceptionName: 'InvalidToken', message: token);
}

class _ExceptionMessage implements Exception {
  _ExceptionMessage({
    required this.exceptionName,
    this.message,
  });
  final dynamic message;
  final String exceptionName;
  @override
  String toString() {
    final Object? message = this.message;
    if (message == null) return exceptionName;
    return '$exceptionName exception: $message';
  }
}
