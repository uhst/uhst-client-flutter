part of uhst_models;

class RelayStream {
  RelayStream({required this.eventSource});
  final EventSource eventSource;

  void close() {
    eventSource.close();
  }
}
