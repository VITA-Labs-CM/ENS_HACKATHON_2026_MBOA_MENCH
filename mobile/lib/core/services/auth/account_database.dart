import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Base SQLite des comptes utilisateurs.
class AccountDatabase {
  AccountDatabase();

  Database? _db;

  Future<void> initialize() async {
    if (_db != null && _db!.isOpen) return;

    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'mboa_accounts.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            identifier TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            role TEXT NOT NULL,
            school TEXT DEFAULT '',
            class_name TEXT DEFAULT '',
            level TEXT DEFAULT '',
            xp INTEGER DEFAULT 0,
            level_number INTEGER DEFAULT 1,
            study_minutes_today INTEGER DEFAULT 0,
            overall_progress REAL DEFAULT 0,
            storage_used_mb REAL DEFAULT 0,
            storage_total_mb REAL DEFAULT 8192,
            created_at TEXT NOT NULL,
            last_login_at TEXT
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_users_identifier ON users(identifier)',
        );
      },
    );
  }

  Database get db {
    if (_db == null || !_db!.isOpen) {
      throw StateError('AccountDatabase not initialized. Call initialize() first.');
    }
    return _db!;
  }

  Future<void> close() async => _db?.close();
}
