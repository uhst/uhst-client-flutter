import 'package:universal_html/html.dart';

class RelayStream {
  final EventSource eventSource;

  RelayStream({required this.eventSource});
  void close() {
    this.eventSource.close();
  }
}
