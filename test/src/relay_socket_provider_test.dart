import 'package:test/test.dart';
import 'package:uhst/src/api_clients/api_client.dart';
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
              apiClient: ApiClient(apiUrl: ''),
              debug: false,
              clientParams: mockClientSocketParams),
          isNotNull);
    });
    test('.createUhstSocket should create RelaySocket for host', () {
      var provider = RelaySocketProvider();
      var mockHostSocketParams = HostSocketParams(token: "responseToken");
      var apiUrl = "test";
      expect(
          provider.createUhstSocket(
              apiClient: ApiClient(
                apiUrl: apiUrl,
              ),
              hostParams: mockHostSocketParams,
              debug: false),
          isNotNull);
    });
  });
}
