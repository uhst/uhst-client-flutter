import 'package:test/test.dart';
import 'package:uhst/src/clients/clients.dart';
import 'package:uhst/src/models/models.dart';
import 'package:uhst/uhst.dart';

void main() {
  group('# RelaySocketProvider', () {
    test('should create RelaySocketProvider', () {
      expect(RelaySocketProvider(), isNotNull);
    });

    test('.createUhstSocket should create RelaySocket for client', () {
      final provider = RelaySocketProvider();
      final mockClientSocketParams = ClientSocketParams(hostId: 'testHostId');
      expect(
        provider.createUhstSocket(
            relayClient: RelayClient(
              relayUrl: 'http://test.test',
            ),
            debug: false,
            clientParams: mockClientSocketParams),
        isNotNull,
      );
    });
    test('.createUhstSocket should create RelaySocket for host', () {
      final provider = RelaySocketProvider();
      final mockHostSocketParams =
          HostSocketParams(token: 'responseToken', clientId: 'testClient');
      const relayUrl = 'test';
      expect(
        provider.createUhstSocket(
          relayClient: RelayClient(
            relayUrl: relayUrl,
          ),
          hostParams: mockHostSocketParams,
          debug: false,
        ),
        isNotNull,
      );
    });
  });
}
