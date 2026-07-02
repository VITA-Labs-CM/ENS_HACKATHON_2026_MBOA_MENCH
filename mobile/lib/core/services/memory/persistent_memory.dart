import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'session_memory.dart';

/// Long-term persistent memory backed by SQLite.
/// Stores conversations, quiz results, mistakes, and learning profile.
class PersistentMemory {
  PersistentMemory();

  Database? _db;

  /// Initialize the database.
  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'mboa_memory.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE memories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id TEXT NOT NULL,
            content TEXT NOT NULL,
            topic TEXT NOT NULL,
            type TEXT NOT NULL,
            importance_score REAL DEFAULT 0.5,
            metadata TEXT DEFAULT '{}',
            created_at TEXT NOT NULL,
            accessed_at TEXT NOT NULL,
            access_count INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE learning_profile (
            student_id TEXT PRIMARY KEY,
            strengths TEXT DEFAULT '[]',
            weaknesses TEXT DEFAULT '[]',
            preferred_style TEXT DEFAULT 'visual',
            total_study_minutes INTEGER DEFAULT 0,
            total_quizzes INTEGER DEFAULT 0,
            average_score REAL DEFAULT 0.0,
            common_mistakes TEXT DEFAULT '[]',
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_memories_student ON memories(student_id)
        ''');
        await db.execute('''
          CREATE INDEX idx_memories_topic ON memories(topic)
        ''');
        await db.execute('''
          CREATE INDEX idx_memories_type ON memories(type)
        ''');
      },
    );
  }

  /// Store a memory entry.
  Future<int> store(String studentId, MemoryEntry entry) async {
    _ensureOpen();
    return await _db!.insert('memories', {
      'student_id': studentId,
      'content': entry.content,
      'topic': entry.topic,
      'type': entry.type.name,
      'importance_score': entry.importanceScore,
      'metadata': jsonEncode(entry.metadata),
      'created_at': entry.timestamp.toIso8601String(),
      'accessed_at': DateTime.now().toIso8601String(),
      'access_count': 0,
    });
  }

  /// Retrieve memories for a student, ordered by recency.
  Future<List<MemoryEntry>> getRecent(String studentId, {int limit = 50}) async {
    _ensureOpen();
    final rows = await _db!.query(
      'memories',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(_rowToEntry).toList();
  }

  /// Search memories by keyword.
  Future<List<MemoryEntry>> search(String studentId, String query) async {
    _ensureOpen();
    final rows = await _db!.query(
      'memories',
      where: 'student_id = ? AND (content LIKE ? OR topic LIKE ?)',
      whereArgs: [studentId, '%$query%', '%$query%'],
      orderBy: 'importance_score DESC, created_at DESC',
      limit: 20,
    );

    // Update access count for retrieved entries
    for (final row in rows) {
      await _db!.update(
        'memories',
        {
          'accessed_at': DateTime.now().toIso8601String(),
          'access_count': (row['access_count'] as int) + 1,
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }

    return rows.map(_rowToEntry).toList();
  }

  /// Get memories by topic.
  Future<List<MemoryEntry>> byTopic(String studentId, String topic) async {
    _ensureOpen();
    final rows = await _db!.query(
      'memories',
      where: 'student_id = ? AND topic = ?',
      whereArgs: [studentId, topic],
      orderBy: 'created_at DESC',
    );
    return rows.map(_rowToEntry).toList();
  }

  /// Get mistakes history for a student.
  Future<List<MemoryEntry>> getMistakes(String studentId) async {
    _ensureOpen();
    final rows = await _db!.query(
      'memories',
      where: 'student_id = ? AND type = ?',
      whereArgs: [studentId, MemoryType.mistake.name],
      orderBy: 'created_at DESC',
      limit: 50,
    );
    return rows.map(_rowToEntry).toList();
  }

  /// Update or create learning profile.
  Future<void> updateProfile(String studentId, LearningProfile profile) async {
    _ensureOpen();
    await _db!.insert(
      'learning_profile',
      {
        'student_id': studentId,
        'strengths': jsonEncode(profile.strengths),
        'weaknesses': jsonEncode(profile.weaknesses),
        'preferred_style': profile.preferredStyle,
        'total_study_minutes': profile.totalStudyMinutes,
        'total_quizzes': profile.totalQuizzes,
        'average_score': profile.averageScore,
        'common_mistakes': jsonEncode(profile.commonMistakes),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get learning profile.
  Future<LearningProfile?> getProfile(String studentId) async {
    _ensureOpen();
    final rows = await _db!.query(
      'learning_profile',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    return LearningProfile(
      studentId: studentId,
      strengths: (jsonDecode(r['strengths'] as String) as List).cast<String>(),
      weaknesses: (jsonDecode(r['weaknesses'] as String) as List).cast<String>(),
      preferredStyle: r['preferred_style'] as String,
      totalStudyMinutes: r['total_study_minutes'] as int,
      totalQuizzes: r['total_quizzes'] as int,
      averageScore: (r['average_score'] as num).toDouble(),
      commonMistakes: (jsonDecode(r['common_mistakes'] as String) as List).cast<String>(),
    );
  }

  /// Get total memory count for a student.
  Future<int> count(String studentId) async {
    _ensureOpen();
    final result = await _db!.rawQuery(
      'SELECT COUNT(*) as cnt FROM memories WHERE student_id = ?',
      [studentId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Delete old, low-importance memories to save space.
  Future<int> prune(String studentId, {int keepCount = 500}) async {
    _ensureOpen();
    final total = await count(studentId);
    if (total <= keepCount) return 0;

    final toDelete = total - keepCount;
    final deleted = await _db!.rawDelete('''
      DELETE FROM memories WHERE id IN (
        SELECT id FROM memories
        WHERE student_id = ?
        ORDER BY importance_score ASC, access_count ASC, created_at ASC
        LIMIT ?
      )
    ''', [studentId, toDelete]);
    return deleted;
  }

  MemoryEntry _rowToEntry(Map<String, Object?> row) {
    return MemoryEntry(
      content: row['content'] as String,
      topic: row['topic'] as String,
      type: MemoryType.values.byName(row['type'] as String),
      timestamp: DateTime.parse(row['created_at'] as String),
      importanceScore: (row['importance_score'] as num).toDouble(),
      metadata: jsonDecode(row['metadata'] as String? ?? '{}'),
    );
  }

  void _ensureOpen() {
    if (_db == null || !_db!.isOpen) {
      throw StateError('PersistentMemory not initialized. Call initialize() first.');
    }
  }

  Future<void> close() async => await _db?.close();
}

/// Student learning profile.
class LearningProfile {
  const LearningProfile({
    required this.studentId,
    this.strengths = const [],
    this.weaknesses = const [],
    this.preferredStyle = 'visual',
    this.totalStudyMinutes = 0,
    this.totalQuizzes = 0,
    this.averageScore = 0,
    this.commonMistakes = const [],
  });

  final String studentId;
  final List<String> strengths, weaknesses, commonMistakes;
  final String preferredStyle;
  final int totalStudyMinutes, totalQuizzes;
  final double averageScore;
}
