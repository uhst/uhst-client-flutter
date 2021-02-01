library uhst;

class Message {
  final String type;
  final String payload;
  final String? responseToken;
  final Map<dynamic, dynamic>? body;
  Message(
      {required this.type,
      required this.payload,
      this.responseToken,
      this.body});
  static fromJson(Map<String, dynamic> map) {
    print({'message': map});
    return Message(
        payload: map['body']['payload'] ?? '',
        type: map['body']['type'],
        body: map['body'],
        responseToken: map['responseToken'] ?? '');
  }
}
