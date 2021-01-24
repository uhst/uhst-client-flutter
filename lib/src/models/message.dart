library uhst;

class Message {
  final dynamic body;
  final String? responseToken;
  Message({required this.body, this.responseToken});
  static fromJson(Map<String, dynamic> map) => Message(
      body: map['body'] ?? '', responseToken: map['responseToken'] ?? '');
}
