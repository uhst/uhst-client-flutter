import 'package:test/test.dart';
import 'package:uhst/src/models/relay_message.dart';

void main() {
  group('# RelayMessage', () {
    test('can be created', () {
      expect(RelayMessage(), isNotNull);
    });

    test('sets and gets string payload', () async {
      var testMessage = RelayMessage();
      await testMessage.setPayload(message: "test");
      var testPayload = await testMessage.getPayload();
      expect(testPayload, equals("test"));
    });
  });
}
