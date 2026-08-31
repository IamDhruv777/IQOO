import 'dart:convert';
import 'memory_date.dart';

// Categories the AI is instructed to classify memories into.
// Kept as a small fixed set to make the extraction prompt deterministic.
const List<String> kMemoryCategories = [
  'event',
  'receipt',
  'contact',
  'document',
  'notice',
  'other',
];

class MemoryAction {
  final String type; // e.g., 'apply', 'register', 'pay'
  final String description;
  final DateTime? dueDate;
  final bool isCompleted;

  const MemoryAction({
    required this.type,
    required this.description,
    this.dueDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory MemoryAction.fromMap(Map<String, dynamic> map) {
    return MemoryAction(
      type: map['type'] as String? ?? 'action',
      description: map['description'] as String? ?? '',
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}

class Memory {
  final String id;
  final String sourceType; // always 'image' for this prototype
  final String imagePath;  // absolute local file path
  final String title;
  final String summary;
  final String category;
  final String extractedText;
  final Map<String, String> entities; // key-value pairs from AI extraction
  final List<MemoryDate> dates;
  final List<MemoryAction> actions;
  final List<double>? embedding;
  final DateTime createdAt;
  final bool reminderSet;
  /// True when AI extraction failed — raw image saved, retry available.
  final bool processingFailed;

  const Memory({
    required this.id,
    this.sourceType = 'image',
    required this.imagePath,
    required this.title,
    this.summary = '',
    this.category = 'other',
    this.extractedText = '',
    this.entities = const {},
    this.dates = const [],
    this.actions = const [],
    this.embedding,
    required this.createdAt,
    this.reminderSet = false,
    this.processingFailed = false,
  });

  /// Returns the first date tagged as 'deadline', or null.
  MemoryDate? get deadline =>
      dates.where((d) => d.isDeadline).isEmpty
          ? null
          : dates.firstWhere((d) => d.isDeadline);

  Memory copyWith({
    String? id,
    String? sourceType,
    String? imagePath,
    String? title,
    String? summary,
    String? category,
    String? extractedText,
    Map<String, String>? entities,
    List<MemoryDate>? dates,
    List<MemoryAction>? actions,
    List<double>? embedding,
    DateTime? createdAt,
    bool? reminderSet,
    bool? processingFailed,
  }) =>
      Memory(
        id: id ?? this.id,
        sourceType: sourceType ?? this.sourceType,
        imagePath: imagePath ?? this.imagePath,
        title: title ?? this.title,
        summary: summary ?? this.summary,
        category: category ?? this.category,
        extractedText: extractedText ?? this.extractedText,
        entities: entities ?? this.entities,
        dates: dates ?? this.dates,
        actions: actions ?? this.actions,
        embedding: embedding ?? this.embedding,
        createdAt: createdAt ?? this.createdAt,
        reminderSet: reminderSet ?? this.reminderSet,
        processingFailed: processingFailed ?? this.processingFailed,
      );

  // --------------- SQLite serialisation ---------------

  Map<String, dynamic> toMap() => {
        'id': id,
        'source_type': sourceType,
        'image_path': imagePath,
        'title': title,
        'summary': summary,
        'category': category,
        'extracted_text': extractedText,
        // Store complex types as JSON strings in SQLite
        'entities': jsonEncode(entities),
        'dates': jsonEncode(dates.map((d) => d.toMap()).toList()),
        'actions': jsonEncode(actions.map((a) => a.toMap()).toList()),
        'embedding': embedding != null ? jsonEncode(embedding) : null,
        'created_at': createdAt.toIso8601String(),
        'reminder_set': reminderSet ? 1 : 0,
        'processing_failed': processingFailed ? 1 : 0,
      };

  factory Memory.fromMap(Map<String, dynamic> map) {
    final entitiesRaw = map['entities'] as String? ?? '{}';
    final datesRaw = map['dates'] as String? ?? '[]';
    final actionsRaw = map['actions'] as String? ?? '[]';
    final embeddingRaw = map['embedding'] as String?;

    Map<String, String> entities = {};
    try {
      final decoded = jsonDecode(entitiesRaw) as Map<String, dynamic>;
      entities = decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {}

    List<MemoryDate> dates = [];
    try {
      final decoded = jsonDecode(datesRaw) as List<dynamic>;
      dates = decoded
          .map((e) => MemoryDate.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}

    List<MemoryAction> actions = [];
    try {
      final decoded = jsonDecode(actionsRaw) as List<dynamic>;
      actions = decoded
          .map((e) => MemoryAction.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}

    List<double>? embedding;
    if (embeddingRaw != null && embeddingRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(embeddingRaw) as List<dynamic>;
        embedding = decoded.map((e) => (e as num).toDouble()).toList();
      } catch (_) {}
    }

    return Memory(
      id: map['id'] as String,
      sourceType: map['source_type'] as String? ?? 'image',
      imagePath: map['image_path'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled',
      summary: map['summary'] as String? ?? '',
      category: map['category'] as String? ?? 'other',
      extractedText: map['extracted_text'] as String? ?? '',
      entities: entities,
      dates: dates,
      actions: actions,
      embedding: embedding,
      createdAt: DateTime.parse(map['created_at'] as String),
      reminderSet: (map['reminder_set'] as int? ?? 0) == 1,
      processingFailed: (map['processing_failed'] as int? ?? 0) == 1,
    );
  }
}
