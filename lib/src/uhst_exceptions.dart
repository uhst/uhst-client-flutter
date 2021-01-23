/// How to determine and use Exception or Error
/// https://stackoverflow.com/questions/17315945/error-vs-exception-in-dart

library UHST;

/// TODO: implement doc HostIdAlreadyInUse
class HostIdAlreadyInUse extends _ExceptionMessage {
  HostIdAlreadyInUse([int? portId])
      : super(exceptionName: 'HostIdAlreadyInUse', message: portId);
}

/// TODO: implement doc ApiUnreachable
class ApiUnreachable extends _ExceptionMessage {
  ApiUnreachable([Uri? message])
      : super(exceptionName: 'ApiUnreachable', message: message);
}

/// TODO: implement doc ApiError
class ApiError extends _ExceptionMessage {
  ApiError([Uri? message]) : super(exceptionName: 'ApiError', message: message);
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
