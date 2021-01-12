import 'package:UHST/uhst.dart';
import 'package:test/test.dart';

void main() {
  group('# UHST', () {
    test('should create UHST', () {
      expect(UHST(), isNotNull);
    });

    test('should accept socketProvider', () {
      // TODO: should accept socketProvider test
      expect('', equals(''));
    });
    test('should accept meetingPointUrl', () {
      var apiUrl = "test";
      expect(UHST(apiUrl: apiUrl), isNotNull);
    });
  });
}
