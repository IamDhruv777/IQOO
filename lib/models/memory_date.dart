// Data model for a date extracted from a memory capture.
// type is one of: 'deadline', 'event_date', 'issue_date', 'other'
// Only 'deadline' type is used for the reminder-suggestion UI.
import 'package:intl/intl.dart';

class MemoryDate {
  final String type;
  final DateTime value;

  const MemoryDate({required this.type, required this.value});

  Map<String, dynamic> toMap() => {
        'type': type,
        'value': value.toIso8601String(),
      };

  factory MemoryDate.fromMap(Map<String, dynamic> map) => MemoryDate(
        type: map['type'] as String,
        value: DateTime.parse(map['value'] as String),
      );

  bool get isDeadline => type == 'deadline';

  String get formattedValue =>
      DateFormat('MMM d, yyyy').format(value);

  String get fullFormattedValue =>
      DateFormat("EEEE, MMM d, yyyy 'at' h:mm a").format(value);
}
