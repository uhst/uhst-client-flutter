library UHST;

import 'dart:convert';

import 'package:UHST/src/uhst_errors.dart';

//  see at https://prafullkumar77.medium.com/flutter-how-to-decode-jwt-token-using-dart-a9657aeaeedf
class Jwt {
  static Map<String, dynamic> decode({required String token}) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw InvalidToken(token, argName: 'Jwt decode');
    }
    var payload = parts[1];
    var decodedPayload = _decodeBase64(string: payload);
    var payloadMap = json.decode(decodedPayload);
    if (payloadMap is! Map<String, dynamic>)
      throw InvalidToken(token, argName: 'Jwt decode payload');
    return payloadMap;
  }

  static String decodeSubject({required String token}) {
    var tokenBody = decode(token: token);
    String? subject = tokenBody['sub'];
    if (subject == null) {
      throw InvalidToken(token, argName: 'Jwt decodeSubject');
    }
    return subject;
  }

  static String _decodeBase64({required String string}) {
    //'-', '+' 62nd char of encoding,  '_', '/' 63rd char of encoding
    String output = string.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      // Pad with trailing '='
      case 0: // No pad chars in this case
        break;
      case 2: // Two pad chars
        output += '==';
        break;
      case 3: // One pad char
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }
}
