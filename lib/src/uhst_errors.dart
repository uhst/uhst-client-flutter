/// How to determine and use Exception or Error
/// https://stackoverflow.com/questions/17315945/error-vs-exception-in-dart
library UHST;

/// TODO: implement doc InvalidToken
class InvalidToken extends ArgumentError {
  InvalidToken(int value, {dynamic? argName})
      : super.value(
          value,
          argName,
          'InvalidToken',
        );
}

/// TODO: implement doc InvalidHostId
class InvalidHostId extends ArgumentError {
  InvalidHostId(int? value, {dynamic? argName})
      : super.value(
          value,
          argName,
          'InvalidHostId',
        );
}

/// TODO: implement doc InvalidClientOrHostId
class InvalidClientOrHostId extends ArgumentError {
  InvalidClientOrHostId(dynamic value, {dynamic? argName})
      : super.value(
          value,
          argName,
          'InvalidClientOrHostId',
        );
}
