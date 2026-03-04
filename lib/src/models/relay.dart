/// Response from Relays directory.
class Relay {
  /// Creates a [Relay].
  Relay({required this.urls, required this.prefix});

  /// Creates a [Relay] from JSON.
  // ignore: prefer_constructors_over_static_methods
  static Relay fromJson(Map<String, dynamic> map) => Relay(
      urls: List<String>.from(map['urls']?.map((i) => i as String)),
      prefix: map['prefix'] ?? '');

  /// The relay URLs.
  final List<String> urls;

  /// The relay prefix.
  final String prefix;
}
