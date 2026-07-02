import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_constants.dart';
import '../../models/user_account.dart';
import 'account_database.dart';

/// Opérations CRUD et authentification sur les comptes SQLite.
class AccountRepository {
  AccountRepository(this._database);

  final AccountDatabase _database;

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<UserAccount> register({
    required String name,
    required String identifier,
    required String password,
    required UserRole role,
    String school = '',
    String className = '',
    String level = '',
  }) async {
    final normalizedId = identifier.trim().toLowerCase();
    final existing = await findByIdentifier(normalizedId);
    if (existing != null) {
      throw AccountException('Un compte existe déjà avec cet identifiant.');
    }

    final account = UserAccount(
      id: const Uuid().v4(),
      name: name.trim(),
      identifier: normalizedId,
      role: role,
      school: school.trim(),
      className: className.trim(),
      level: level.trim(),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    await _database.db.insert(
      'users',
      {
        ...account.toMap(),
        'password_hash': hashPassword(password),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return account;
  }

  Future<UserAccount> login({
    required String identifier,
    required String password,
  }) async {
    final account = await findByIdentifier(identifier.trim().toLowerCase());
    if (account == null) {
      throw AccountException('Identifiant ou mot de passe incorrect.');
    }

    final rows = await _database.db.query(
      'users',
      columns: ['password_hash'],
      where: 'id = ?',
      whereArgs: [account.id],
      limit: 1,
    );
    final storedHash = rows.first['password_hash'] as String;
    if (storedHash != hashPassword(password)) {
      throw AccountException('Identifiant ou mot de passe incorrect.');
    }

    final now = DateTime.now();
    await _database.db.update(
      'users',
      {'last_login_at': now.toIso8601String()},
      where: 'id = ?',
      whereArgs: [account.id],
    );

    return account.copyWith(lastLoginAt: now);
  }

  Future<UserAccount?> findById(String id) async {
    final rows = await _database.db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserAccount.fromMap(rows.first);
  }

  Future<UserAccount?> findByIdentifier(String identifier) async {
    final rows = await _database.db.query(
      'users',
      where: 'identifier = ?',
      whereArgs: [identifier.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserAccount.fromMap(rows.first);
  }

  Future<UserAccount?> getLastLoggedInUser() async {
    final rows = await _database.db.query(
      'users',
      where: 'last_login_at IS NOT NULL',
      orderBy: 'last_login_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserAccount.fromMap(rows.first);
  }

  Future<void> updateAccount(UserAccount account) async {
    await _database.db.update(
      'users',
      {
        'name': account.name,
        'school': account.school,
        'class_name': account.className,
        'level': account.level,
        'xp': account.xp,
        'level_number': account.levelNumber,
        'study_minutes_today': account.studyMinutesToday,
        'overall_progress': account.overallProgress,
        'storage_used_mb': account.storageUsedMb,
        'storage_total_mb': account.storageTotalMb,
        if (account.lastLoginAt != null)
          'last_login_at': account.lastLoginAt!.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }
}

class AccountException implements Exception {
  AccountException(this.message);
  final String message;

  @override
  String toString() => message;
}
