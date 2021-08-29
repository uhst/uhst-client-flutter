part of uhst_models;

/// Response from Relays directory
class Relay {
  Relay({required this.urls, required this.prefix});
  // Reason: use this as callback
  // ignore: prefer_constructors_over_static_methods
  static Relay fromJson(Map<String, dynamic> map) => Relay(
      urls: List<String>.from(map['urls']?.map((i) => i as String)),
      prefix: map['prefix'] ?? '');
  final List<String> urls;
  final String prefix;
}
