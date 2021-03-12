import 'package:test/test.dart';
import 'package:uhst/src/clients/relay_client.dart';
import 'package:uhst/src/models/socket_params.dart';
import 'package:uhst/uhst.dart';

void main() {
  group('# RelaySocketProvider', () {
    test('should create RelaySocketProvider', () {
      expect(RelaySocketProvider(), isNotNull);
    });

    test('.createUhstSocket should create RelaySocket for client', () {
      var provider = RelaySocketProvider();
      var mockClientSocketParams = ClientSocketParams(hostId: "testHostId");
      expect(
          provider.createUhstSocket(
              relayClient: RelayClient(relayUrl: ''),
              debug: false,
              clientParams: mockClientSocketParams),
          isNotNull);
    });
    test('.createUhstSocket should create RelaySocket for host', () {
      var provider = RelaySocketProvider();
      var mockHostSocketParams = HostSocketParams(token: "responseToken");
      var relayUrl = "test";
      expect(
          provider.createUhstSocket(
              relayClient: RelayClient(
                relayUrl: relayUrl,
              ),
              hostParams: mockHostSocketParams,
              debug: false),
          isNotNull);
    });
  });
}
