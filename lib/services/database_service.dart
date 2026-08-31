import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/memory.dart';

/// Local SQLite persistence layer.
/// All memories are stored on-device; no cloud sync in this prototype.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  static const _dbName = 'memory_lens.db';
  static const _dbVersion = 3;
  static const _tableName = 'memories';

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _dbName);
    return openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        source_type TEXT NOT NULL,
        image_path TEXT NOT NULL,
        title TEXT NOT NULL,
        summary TEXT,
        category TEXT,
        extracted_text TEXT,
        entities TEXT,
        dates TEXT,
        actions TEXT,
        embedding TEXT,
        created_at TEXT NOT NULL,
        reminder_set INTEGER DEFAULT 0,
        processing_failed INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN actions TEXT DEFAULT "[]"');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN embedding TEXT');
    }
  }

  Future<void> insertMemory(Memory memory) async {
    final db = await database;
    await db.insert(
      _tableName,
      memory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMemory(Memory memory) async {
    final db = await database;
    await db.update(
      _tableName,
      memory.toMap(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  Future<void> deleteMemory(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Memory>> getAllMemories() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'created_at DESC');
    return rows.map(Memory.fromMap).toList();
  }

  Future<Memory?> getMemoryById(String id) async {
    final db = await database;
    final rows =
        await db.query(_tableName, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Memory.fromMap(rows.first);
  }

  Future<List<Memory>> getUpcomingActions() async {
    final all = await getAllMemories();
    final upcoming = <Memory>[];
    final now = DateTime.now();

    for (final m in all) {
      if (m.actions.any((a) =>
          !a.isCompleted &&
          a.dueDate != null &&
          a.dueDate!.isAfter(now))) {
        upcoming.add(m);
      }
    }
    // Sort by nearest upcoming date
    upcoming.sort((a, b) {
      final aDate = a.actions
          .where((x) => x.dueDate != null && x.dueDate!.isAfter(now))
          .map((x) => x.dueDate!)
          .reduce((min, curr) => curr.isBefore(min) ? curr : min);
      final bDate = b.actions
          .where((x) => x.dueDate != null && x.dueDate!.isAfter(now))
          .map((x) => x.dueDate!)
          .reduce((min, curr) => curr.isBefore(min) ? curr : min);
      return aDate.compareTo(bDate);
    });

    return upcoming;
  }

  Future<List<Memory>> getRelatedMemories(Memory m) async {
    final all = await getAllMemories();
    final related = <Memory>[];

    for (final other in all) {
      if (other.id == m.id) continue;
      
      // Simple logic: same category AND at least one matching entity key-value
      if (other.category == m.category) {
        bool sharesEntity = false;
        m.entities.forEach((k, v) {
          if (other.entities[k] == v) sharesEntity = true;
        });

        // Or if they share a very similar title/summary
        bool similarText = false;
        if (m.title.isNotEmpty && other.title.toLowerCase().contains(m.title.toLowerCase().split(' ').first)) {
            similarText = true;
        }

        if (sharesEntity || similarText) {
          related.add(other);
        }
      }
    }
    return related.take(5).toList();
  }

  /// Simple keyword fallback search used when the AI search-ranking call fails.
  /// Searches across title, summary, and extracted_text columns.
  /// NOTE: This is intentionally naive — production would use embeddings + vector DB.
  Future<List<Memory>> keywordSearch(String query) async {
    if (query.trim().isEmpty) return getAllMemories();
    final db = await database;
    final terms = query.toLowerCase().split(RegExp(r'\s+'));
    // Build a WHERE clause that ANDs all search terms across the three columns
    final conditions = terms
        .map((_) =>
            '(LOWER(title) LIKE ? OR LOWER(summary) LIKE ? OR LOWER(extracted_text) LIKE ?)')
        .join(' AND ');
    final args = terms.expand((t) => ['%$t%', '%$t%', '%$t%']).toList();
    final rows = await db.query(
      _tableName,
      where: conditions,
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return rows.map(Memory.fromMap).toList();
  }

  /// Checks whether seed data has already been inserted.
  Future<bool> isSeedDataInserted() async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM $_tableName WHERE id LIKE 'seed_%'");
    return (result.first['cnt'] as int) > 0;
  }

  Future<void> close() async => _db?.close();
}
