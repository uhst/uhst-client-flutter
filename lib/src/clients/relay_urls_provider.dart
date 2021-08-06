part of uhst_clients;

class _RelayUrlsProviderConsts {
  static const relaysListUrl =
      'https://raw.githubusercontent.com/uhst/relays/main/list.json';
}

// Find the best relay
class RelayUrlsProvider {
  RelayUrlsProvider() : networkClient = NetworkClient();
  NetworkClient networkClient;

  Future<List<String>> getRelayUrls(String? hostId) async {
    final List<Relay> relays = List<Relay>.from((await networkClient.get(
            url: _RelayUrlsProviderConsts.relaysListUrl) as List<dynamic>)
        .map((i) => Relay.fromJson(i as Map<String, dynamic>)));
    if (hostId != null) {
      // if hostId get all URLs for the hostId
      final String prefix = hostId.split('-')[0];
      for (final Relay relay in relays) {
        if (relay.prefix == prefix) {
          return relay.urls;
        }
      }
      // there are no relays serving this prefix
      return [];
    }
    // if no hostId, get all URLs
    final List<String> urls = [];
    relays.forEach((x) => x.urls.forEach(urls.add));
    return urls;
  }

  Future<String> getBestRelayUrl(String? hostId) async {
    final relayUrls = await getRelayUrls(hostId);
    final completer = Completer<String>();
    var failed = 0;
    if (relayUrls.isEmpty) {
      completer.completeError(RelayUnreachable());
    } else {
      final rng = Random();
      const maxInt = 4294967296;
      relayUrls.sort((a, b) => rng.nextInt(maxInt) - rng.nextInt(maxInt));
      relayUrls.sublist(0, min(relayUrls.length, 10)).forEach((url) async {
        try {
          final qParams = <String, String>{};
          qParams['action'] = 'ping';
          qParams['timestamp'] =
              DateTime.now().millisecondsSinceEpoch.toString();
          final response = PingResponse.fromJson(
              await networkClient.post(url: url, queryParameters: qParams));
          if (!completer.isCompleted) {
            completer.complete(url);
          }
        } on Exception catch (e) {
          failed++;
          if (!completer.isCompleted && failed == relayUrls.length) {
            completer.completeError(e);
          }
        }
      });
    }
    return completer.future;
  }
}
