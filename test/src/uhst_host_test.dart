import 'package:test/test.dart';

void main() {
  group('# UhstHost', () {
    test('can host', () {
      // const mockApi = <UhstApiClient>{};
      // const mockSocketProvider = <UhstSocketProvider>{};
      // const mockSocket = <UhstSocket>{};
      // const mockToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVzcG9uc2VUb2tlbiIsImhvc3RJZCI6InRlc3RIb3N0IiwiY2xpZW50SWQiOiI4ODk2OGUzYi03YTQ1LTQwMTMtYjY2OC1iNWIwMDIwMTQ2M2EiLCJpYXQiOjE1OTk4ODI1NjB9.Ck583aKIeEcEsvCVlNgpMgLrVM1JQQC4vB8PCaTU-pA";
      // Function? messageHandler;

      // Stream<UhstSocketEventType> mockStreamClose = (() async*{
      //   yield UhstSocketEventType.close;
      // })();

      // mockApi.initHost = stub().returns(<HostConfiguration>{
      //     hostId: "testHostId",
      //     hostToken: "testHostToken",
      //     receiveUrl: "testReceiveUrl",
      //     sendUrl: "testSendUrl",
      // });

      // mockApi.subscribeToMessages = (token, handler, receiveUrl) => {
      //     expect(token,equals("testHostToken"));
      //     expect(receiveUrl,equals("testReceiveUrl"));
      //     messageHandler = handler;
      //     return Promise.resolve(<MessageStream>{
      //         close: mockStreamClose
      //     });
      // }

      // mockSocket.handleMessage = (message: HostMessage) => {
      //     expect(message.responseToken).to.equal(mockToken);
      //     expect(message.body).to.equal("testClientMessage");
      // }

      // mockSocketProvider.createUhstSocket = (apiClient, params: HostSocketParams, debug) => {
      //     expect(apiClient).to.equal(mockApi);
      //     expect(params.type).to.equal("host");
      //     expect(params.token).to.equal(mockToken);
      //     expect(params.sendUrl).to.equal("testSendUrl");
      //     return mockSocket;
      // }

      // const uhstHost: UhstHost = new UhstHost(mockApi, mockSocketProvider, "testHostId", false);
      // uhstHost.on("ready", () => {
      //     expect(uhstHost.hostId).to.equal("testHostId");
      //     messageHandler(<HostMessage>{
      //         responseToken: mockToken,
      //         body: "testClientMessage"
      //     });
      // });
      // uhstHost.on("connection", (socket) => {
      //     expect(socket).to.not.be.undefined;
      //     expect(mockStreamClose).to.not.have.been.called;
      //     done();
      // });

      // expect(mockApi.initHost).to.have.been.calledWith("testHostId");
    });
  });
}
