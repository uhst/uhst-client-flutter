import 'package:test/test.dart';
import 'package:uhst/src/utils/jwt.dart';

const token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwiY2xpZW50SWQiOiJ0ZXN0SWQiLCJpYXQiOjE1MTYyMzkwMjJ9.x8ZFLkeSZENZGTowMW_LWGlyGwBlL-zelVbOn0UCygk';

void main() {
  group('# jwt', () {
    test('decode body', () {
      var result = Jwt.decode(token: token);
      var expectResult = {
        "sub": "1234567890",
        "clientId": "testId",
        "iat": 1516239022
      };
      expect(result, equals(expectResult));
    });
    test('get [clientId]', () {
      var result = Jwt.decodeSubject(token: token);
      expect(result, equals('testId'));
    });
  });
}
