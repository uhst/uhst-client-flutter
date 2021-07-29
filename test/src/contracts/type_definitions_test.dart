import 'package:test/test.dart';
import 'package:uhst/src/contracts/contracts.dart';

const stringTypes = ['string', 'blob', 'typedData', 'byteBuffer'];
const payloadTypes = [
  PayloadType.string,
  PayloadType.blob,
  PayloadType.typedData,
  PayloadType.byteBuffer
];

void main() {
  group('# type definitions', () {
    test('get string from payload type', () {
      final result = <String>[];
      for (final type in payloadTypes) {
        result.add(type.toStringValue());
      }

      expect(result, equals(stringTypes));
    });
    test('get payload type from string', () {
      final result = <PayloadType>[];
      for (final type in stringTypes) {
        result.add(PayloadType.fromString[type]);
      }
      expect(result, equals(payloadTypes));
    });
  });
}
