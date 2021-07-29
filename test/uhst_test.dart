import 'package:test/test.dart';
import 'package:uhst/uhst.dart';

void main() {
  group('# uhst', () {
    test('should create uhst', () {
      expect(UHST(), isNotNull);
    });

    // test('should accept socketProvider', () {
    //   expect('', equals(''));
    // });
    test('should accept meetingPointUrl', () {
      const relayUrl = 'test';
      expect(UHST(relayUrl: relayUrl), isNotNull);
    });
  });
}
