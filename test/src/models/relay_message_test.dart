import 'package:test/test.dart';
import 'package:uhst/src/models/models.dart';

void main() {
  group('# RelayMessage', () {
    test('can be created', () {
      expect(RelayMessage(), isNotNull);
    });

    test('sets and gets string payload', () async {
      final testMessage = RelayMessage();
      await testMessage.setPayload(message: 'test');
      final testPayload = await testMessage.getPayload();
      expect(testPayload, equals('test'));
    });
  });
}
