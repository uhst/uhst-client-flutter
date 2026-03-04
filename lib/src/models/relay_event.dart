import 'dart:convert';

import 'package:meta/meta.dart';

import '../contracts/relay_event_type.dart';
import '../contracts/type_definitions.dart';
import 'message.dart';

/// Special events sent by relay.
/// Used to notify host or client about [RelayEventType] events.
@immutable
class RelayEvent extends Message {
  /// Creates a [RelayEvent].
  const RelayEvent({
    required this.eventType,
    required super.payload,
    required super.type,
    super.responseToken,
  });

  /// Creates a [RelayEvent] from JSON.
  factory RelayEvent.fromJson(dynamic json) {
    final jsonMap = jsonDecode(json);
    if (jsonMap is! Map<String, dynamic>) {
      throw ArgumentError.value(jsonMap, 'json', 'has to be map');
    }
    return RelayEvent(
      eventType: RelayEventType.fromString(jsonMap['eventType']),
      payload: jsonMap['body'],
      type: PayloadType.string,
    );
  }

  /// The relay event type.
  final RelayEventType eventType;
}
