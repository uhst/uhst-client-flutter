library UHST;

class Message {
  final dynamic body;
  Message({required this.body});
  static fromJson(Map<String, dynamic> map) => Message(body: map['body'] ?? '');
}
