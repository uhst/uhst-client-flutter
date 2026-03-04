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

/// Base class for all UHST exceptions.
sealed class UhstException implements Exception {
  /// Creates an [UhstException] with an optional [message].
  UhstException([this.message]);

  /// The exception message.
  final dynamic message;

  @override
  String toString() {
    final Object? message = this.message;
    if (message == null) return '$runtimeType';
    return '$runtimeType: $message';
  }
}

/// This exception is used for Relay connection,
/// when socket receives hostClosed event.
final class HostDisconnected extends UhstException {
  /// Creates a [HostDisconnected] exception.
  HostDisconnected([super.message]);
}

/// Exception thrown when the host ID is invalid.
final class InvalidHostId extends UhstException {
  /// Creates an [InvalidHostId] exception.
  InvalidHostId([super.message]);
}

/// Exception thrown when the host ID is already in use.
final class HostIdAlreadyInUse extends UhstException {
  /// Creates a [HostIdAlreadyInUse] exception.
  HostIdAlreadyInUse([super.message]);
}

/// Exception thrown when the client or host ID is invalid.
final class InvalidClientOrHostId extends UhstException {
  /// Creates an [InvalidClientOrHostId] exception.
  InvalidClientOrHostId([super.message]);
}

/// Exception thrown when the network is unreachable.
final class NetworkUnreachable extends UhstException {
  /// Creates a [NetworkUnreachable] exception.
  NetworkUnreachable([super.message]);
}

/// Exception thrown for network-related errors with response codes.
final class NetworkException extends UhstException {
  /// Creates a [NetworkException] with a [responseCode].
  NetworkException({
    required this.responseCode,
    dynamic message,
  }) : super(message);

  /// The HTTP response code.
  final int responseCode;
}

/// Exception thrown when the relay server is unreachable.
final class RelayUnreachable extends UhstException {
  /// Creates a [RelayUnreachable] exception.
  RelayUnreachable([super.message]);
}

/// Exception thrown for relay-related errors.
final class RelayException extends UhstException {
  /// Creates a [RelayException].
  RelayException([super.message]);
}

/// Exception thrown when the token is invalid.
final class InvalidToken extends UhstException {
  /// Creates an [InvalidToken] exception.
  InvalidToken([super.message]);
}
