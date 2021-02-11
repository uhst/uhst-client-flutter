import 'package:test/test.dart';
import 'package:uhst/src/contracts/type_definitions.dart';

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
      var result = <String>[];
      payloadTypes.forEach((type) {
        result.add(type.toStringValue());
      });

      expect(result, equals(stringTypes));
    });
    test('get payload type from string', () {
      var result = <PayloadType>[];
      stringTypes.forEach((type) {
        result.add(PayloadType.fromString[type]);
      });
      expect(result, equals(payloadTypes));
    });
  });
}
