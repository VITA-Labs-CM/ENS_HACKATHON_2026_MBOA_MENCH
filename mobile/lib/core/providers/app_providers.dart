import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/auth/account_repository.dart';
import 'account_providers.dart';

/// Provider pour SharedPreferences — persistance locale légère.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

/// Mode de thème de l'application (clair / sombre / système).
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>(
  (ref) => ThemeModeNotifier(ref.watch(sharedPreferencesProvider)),
);

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier(this._prefs) : super(_loadTheme(_prefs));

  final SharedPreferences _prefs;

  static AppThemeMode _loadTheme(SharedPreferences prefs) {
    final value = prefs.getString(AppConstants.themeModeKey);
    return AppThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    await _prefs.setString(AppConstants.themeModeKey, mode.name);
  }
}

/// État de session utilisateur — lié au compte SQLite.
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>(
  (ref) => SessionNotifier(
    ref.watch(sharedPreferencesProvider),
    ref.watch(accountRepositoryProvider),
    ref,
  ),
);

class SessionState {
  const SessionState({
    this.isAuthenticated = false,
    this.isOfflineMode = false,
    this.role,
    this.userName,
    this.userId,
    this.onboardingCompleted = false,
  });

  final bool isAuthenticated;
  final bool isOfflineMode;
  final UserRole? role;
  final String? userName;
  final String? userId;
  final bool onboardingCompleted;

  SessionState copyWith({
    bool? isAuthenticated,
    bool? isOfflineMode,
    UserRole? role,
    String? userName,
    String? userId,
    bool? onboardingCompleted,
  }) {
    return SessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      role: role ?? this.role,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._prefs, this._accounts, this._ref) : super(_loadSession(_prefs));

  final SharedPreferences _prefs;
  final AccountRepository _accounts;
  final Ref _ref;

  static SessionState _loadSession(SharedPreferences prefs) {
    final onboarding = prefs.getBool(AppConstants.onboardingKey) ?? false;
    final roleName = prefs.getString(AppConstants.userRoleKey);
    final userName = prefs.getString(AppConstants.sessionKey);
    final userId = prefs.getString(AppConstants.userIdKey);
    final role = roleName != null
        ? UserRole.values.firstWhere((r) => r.name == roleName, orElse: () => UserRole.student)
        : null;

    return SessionState(
      isAuthenticated: userId != null && userName != null,
      role: role,
      userName: userName,
      userId: userId,
      onboardingCompleted: onboarding,
    );
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(AppConstants.onboardingKey, true);
    state = state.copyWith(onboardingCompleted: true);
  }

  Future<void> loginFromAccount({
    required String userId,
    required String name,
    required UserRole role,
    bool offline = false,
  }) async {
    await _prefs.setString(AppConstants.sessionKey, name);
    await _prefs.setString(AppConstants.userRoleKey, role.name);
    await _prefs.setString(AppConstants.userIdKey, userId);
    await _prefs.setString(AppConstants.lastUserIdKey, userId);
    state = state.copyWith(
      isAuthenticated: true,
      isOfflineMode: offline,
      role: role,
      userName: name,
      userId: userId,
    );
    _ref.invalidate(currentAccountProvider);
    _ref.invalidate(lastAccountProvider);
  }

  Future<void> loginOffline() async {
    final lastId = _prefs.getString(AppConstants.lastUserIdKey);
    if (lastId == null) {
      throw AccountException('Aucune session locale disponible.');
    }
    final account = await _accounts.findById(lastId);
    if (account == null) {
      throw AccountException('Compte local introuvable.');
    }
    await loginFromAccount(
      userId: account.id,
      name: account.name,
      role: account.role,
      offline: true,
    );
  }

  Future<void> logout() async {
    await _prefs.remove(AppConstants.sessionKey);
    await _prefs.remove(AppConstants.userRoleKey);
    await _prefs.remove(AppConstants.userIdKey);
    state = SessionState(onboardingCompleted: state.onboardingCompleted);
    _ref.invalidate(currentAccountProvider);
  }
}

/// Index de navigation pour la barre inférieure élève.
final studentNavIndexProvider = StateProvider<int>((ref) => 0);

/// Index de navigation pour la barre latérale / inférieure enseignant.
final teacherNavIndexProvider = StateProvider<int>((ref) => 0);
