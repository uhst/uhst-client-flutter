import 'message.dart';

class HostMessage extends Message {
  final String responseToken;
  HostMessage({dynamic? body, required this.responseToken}) : super(body: body);
}
