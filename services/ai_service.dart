import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/memory.dart';
import '../models/memory_date.dart';
import '../config/api_config.dart';

class AiSearchResult {
  final String answer;
  final List<String> rankedIds;

  AiSearchResult({required this.answer, required this.rankedIds});
}

/// Handles all AI API interactions — extraction from image and search ranking.
///
/// HACKATHON SHORTCUT: Both calls go to a single Gemini multimodal endpoint.
/// This avoids integrating separate OCR, embedding, and vector-search services,
/// which would be the production-grade approach.
///
/// Search ranking sends all memory summaries as text to the AI and asks it
/// to rank by relevance. This works fine at demo scale (5–15 memories) but
/// is O(n) in API cost and latency — NOT a production pattern.
class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final _uuid = const Uuid();

  // ─────────────────────────────────────────────────────────────────────────
  // A. EXTRACTION — image → structured Memory
  // ─────────────────────────────────────────────────────────────────────────

  /// Sends the image to Gemini and extracts structured memory fields.
  /// Returns a Memory with [processingFailed] = true if parsing fails,
  /// so the caller can still save the raw capture.
  Future<Memory> extractFromImage(File imageFile, String localPath) async {
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    final mimeType = _inferMimeType(imageFile.path);

    final prompt = _buildExtractionPrompt();

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            },
            {'text': prompt},
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,       // low temp → deterministic JSON output
        'maxOutputTokens': 8192,
      },
    });

    try {
      final response = await http
          .post(
            Uri.parse(
                '$_baseUrl/$kGeminiModel:generateContent?key=$kGeminiApiKey'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode != 200) {
        throw Exception('Gemini API error: ${response.statusCode} ${response.body}');
      }

      return await _parseExtractionResponse(response.body, localPath);
    } catch (e) {
      // On any failure, return a Memory with processingFailed = true.
      // The caller must still persist this so the capture is never lost.
      return Memory(
        id: _uuid.v4(),
        imagePath: localPath,
        title: 'Untitled capture',
        createdAt: DateTime.now(),
        processingFailed: true,
      );
    }
  }

  Future<Memory> _parseExtractionResponse(String responseBody, String localPath) async {
    try {
      final resp = jsonDecode(responseBody) as Map<String, dynamic>;
      final candidates = resp['candidates'] as List<dynamic>;
      final content = candidates.first['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      String rawText = parts.first['text'] as String;

      // Strip markdown fences if the model added them despite instructions
      rawText = rawText
          .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
          .trim();

      final data = jsonDecode(rawText) as Map<String, dynamic>;

      // Parse entities
      Map<String, String> entities = {};
      if (data['entities'] is Map) {
        final raw = data['entities'] as Map<String, dynamic>;
        entities = raw.map((k, v) => MapEntry(k, v?.toString() ?? ''));
      }

      // Parse dates
      List<MemoryDate> dates = [];
      if (data['dates'] is List) {
        for (final d in data['dates'] as List<dynamic>) {
          try {
            final map = d as Map<String, dynamic>;
            dates.add(MemoryDate(
              type: map['type'] as String? ?? 'other',
              value: DateTime.parse(map['value'] as String),
            ));
          } catch (_) {
            // Skip unparseable date entries
          }
        }
      }

      // Parse actions
      List<MemoryAction> actions = [];
      if (data['actions'] is List) {
        for (final a in data['actions'] as List<dynamic>) {
          try {
            final map = a as Map<String, dynamic>;
            DateTime? dueDate;
            if (map['dueDate'] != null) {
              dueDate = DateTime.parse(map['dueDate'] as String);
            }
            actions.add(MemoryAction(
              type: map['type'] as String? ?? 'other',
              description: map['description'] as String? ?? 'Task',
              dueDate: dueDate,
            ));
          } catch (_) {
            // Skip unparseable action entries
          }
        }
      }

      final category = _normaliseCategory(data['category'] as String? ?? 'other');

      final title = (data['title'] as String? ?? 'Untitled').trim();
      final summary = (data['summary'] as String? ?? '').trim();
      final extractedText = (data['extracted_text'] as String? ?? '').trim();

      // Generate vector embedding for true semantic search
      List<double>? embedding;
      try {
        final textToEmbed = 'Title: $title\nSummary: $summary\nText: $extractedText';
        embedding = await generateEmbedding(textToEmbed);
      } catch (_) {
        // If embedding fails, memory still saves but without vector search capability
      }

      return Memory(
        id: _uuid.v4(),
        imagePath: localPath,
        title: title,
        summary: summary,
        category: category,
        extractedText: extractedText,
        entities: entities,
        dates: dates,
        actions: actions,
        embedding: embedding,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return Memory(
        id: const Uuid().v4(),
        imagePath: localPath,
        title: 'Untitled capture',
        createdAt: DateTime.now(),
        processingFailed: true,
      );
    }
  }

  Future<List<double>> generateEmbedding(String text) async {
    final body = jsonEncode({
      'content': {
        'parts': [
          {'text': text}
        ]
      }
    });

    final response = await http.post(
      Uri.parse('$_baseUrl/text-embedding-004:embedContent?key=$kGeminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Embedding failed: ${response.body}');
    }

    final resp = jsonDecode(response.body) as Map<String, dynamic>;
    final embedding = resp['embedding']['values'] as List<dynamic>;
    return embedding.map((e) => (e as num).toDouble()).toList();
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0.0;
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0.0 || normB == 0.0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // B. SEARCH RANKING — query + memory list → ordered IDs + direct answer
  // ─────────────────────────────────────────────────────────────────────────

  /// Search implementation using the massive Context Window Shortcut.
  /// Bypasses strict vector similarity and sends all memory data (up to limits)
  /// directly to Gemini, allowing flawless multilingual (Hinglish/Marathi)
  /// reasoning and exact date matching for the Hackathon demo.
  Future<AiSearchResult?> rankMemoriesForQuery(
      String query, List<Memory> memories) async {
    if (memories.isEmpty) return null;

    // Sort by newest first, take up to 30 to stay safe on tokens while maximizing demo context
    final topMemories = memories.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final searchMemories = topMemories.take(30).toList();

    final memoryList = searchMemories.map((m) => {
          'id': m.id,
          'title': m.title,
          'summary': m.summary,
          'extracted_text': m.extractedText, 
          'category': m.category,
          'entities': m.entities,
          'dates': m.dates.map((d) => '${d.type}: ${d.formattedValue}').toList(),
          'actions': m.actions.map((a) => '${a.type}: ${a.description} (due: ${a.dueDate})').toList(),
        });

    final prompt = '''
You are MemoryLens, an advanced memory reasoning engine. The user is asking a question about their saved memories.
The query might be in English, Hinglish, or Marathi.

1. Understand the user's intent.
2. Search through the provided memories for all relevant information.
3. SYNTHESIZE a comprehensive answer. If the answer requires combining facts from MULTIPLE memories, do so intelligently.
4. Give specific, extracted details (deadlines, amounts, steps) from the `extracted_text`, `entities`, and `actions`.
5. If you use multiple memories to answer, explicitly mention them in your answer.

Special queries:
- If the user asks "What should I not forget?" or "What's coming up?", focus heavily on the `actions` and upcoming `dates` from the memories.

User query: "$query"

Available memories:
${jsonEncode(memoryList.toList())}

Return ONLY a valid JSON object with the following structure (no prose, no markdown fences):
{
  "answer": "Your synthesized, conversational answer. Be direct and specific. If combining sources, mention them.",
  "rankedIds": ["id1", "id2", "id3"] // The memory IDs that contributed to the answer, in order of relevance. Empty array if none.
}
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens': 8192,
      },
    });

    try {
      final response = await http
          .post(
            Uri.parse(
                '$_baseUrl/$kGeminiModel:generateContent?key=$kGeminiApiKey'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) return null;

      final resp = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = resp['candidates'] as List<dynamic>;
      final content = candidates.first['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      String rawText = (parts.first['text'] as String)
          .replaceAll(RegExp(r'^```[a-z]*\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
          .trim();

      final decoded = jsonDecode(rawText) as Map<String, dynamic>;
      final rankedIds = (decoded['rankedIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final answer = decoded['answer']?.toString() ?? '';
      
      return AiSearchResult(answer: answer, rankedIds: rankedIds);
    } catch (_) {
      // On any failure, return null — caller will fall back to keyword search
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  String _buildExtractionPrompt() => '''
Analyze this image carefully and extract all visible information.

Return ONLY a single valid JSON object with these exact fields (no prose, no markdown fences):
{
  "title": "A short 3-7 word human-readable title",
  "summary": "One sentence describing what this image shows",
  "category": "one of: event, receipt, contact, document, notice, other",
  "extracted_text": "All text visible in the image, exactly as written",
  "entities": {
    // Key-value pairs relevant to the category, e.g.:
    // For event: "event_name", "location", "organizer"
    // For receipt: "merchant", "amount", "payment_method"
    // For contact: "name", "phone", "email", "company"
    // For notice: "subject", "issuing_body"
    // Use snake_case keys, string values
  },
  "dates": [
    // Array of date objects found in the image. May be empty [].
    // Each object: { "type": "deadline|event_date|issue_date|other", "value": "ISO 8601 datetime" }
    // Normalize all dates to ISO 8601. Assume current year is 2026.
  ],
  "actions": [
    // Array of actionable tasks required by the user based on the image. May be empty [].
    // Examples: "Apply for internship", "Register for hackathon", "Pay electricity bill".
    // Each object: { "type": "apply|register|pay|attend|other", "description": "Short description of the action", "dueDate": "ISO 8601 datetime or null if no deadline" }
  ]
}

Return nothing else — just the JSON object.
''';

  String _normaliseCategory(String raw) {
    final lower = raw.toLowerCase().trim();
    return kMemoryCategories.contains(lower) ? lower : 'other';
  }

  String _inferMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
