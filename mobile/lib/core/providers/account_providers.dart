import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_account.dart';
import '../services/auth/account_database.dart';
import '../services/auth/account_repository.dart';
import 'app_providers.dart';

final accountDatabaseProvider = Provider<AccountDatabase>((ref) {
  final database = AccountDatabase();
  ref.onDispose(() => database.close());
  return database;
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(accountDatabaseProvider));
});

/// Compte connecté, chargé depuis SQLite.
final currentAccountProvider = FutureProvider<UserAccount?>((ref) async {
  final session = ref.watch(sessionProvider);
  final userId = session.userId;
  if (!session.isAuthenticated || userId == null) return null;
  return ref.read(accountRepositoryProvider).findById(userId);
});

/// Dernier compte connecté (mode hors ligne).
final lastAccountProvider = FutureProvider<UserAccount?>((ref) async {
  return ref.read(accountRepositoryProvider).getLastLoggedInUser();
});
