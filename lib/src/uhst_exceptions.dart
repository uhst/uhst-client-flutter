/// How to determine and use Exception or Error
/// https://stackoverflow.com/questions/17315945/error-vs-exception-in-dart

library UHST;

// FIXME: does we need to use IO or only html will be enough?
import 'dart:io';

/// TODO: implement doc HostIdAlreadyInUse
class HostIdAlreadyInUse extends SocketException {
  HostIdAlreadyInUse({
    required int? port,
    InternetAddress? address,
    OSError? osError,
  }) : super('HostIdAlreadyInUse',
            address: address, osError: osError, port: port);
}

/// TODO: implement doc ApiUnreachable
class ApiUnreachable extends HttpException {
  ApiUnreachable({required Uri? uri}) : super('ApiUnreachable', uri: uri);
}

/// TODO: implement doc ApiError
class ApiError extends HttpException {
  ApiError({required Uri? uri}) : super('ApiError', uri: uri);
}
