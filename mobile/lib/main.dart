import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart';
import 'core/providers/account_providers.dart';
import 'core/services/auth/account_database.dart';
import 'core/services/database/database_init.dart';
import 'core/constants/app_constants.dart';

/// Point d'entrée de MBOA MENCH.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSqflite();
  final prefs = await SharedPreferences.getInstance();

  final accountDb = AccountDatabase();
  await accountDb.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        accountDatabaseProvider.overrideWithValue(accountDb),
      ],
      child: const MboaMenchApp(),
    ),
  );
}

/// Widget racine — thème, router, MaterialApp.
class MboaMenchApp extends ConsumerWidget {
  const MboaMenchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    final brightness = switch (themeMode) {
      AppThemeMode.light => Brightness.light,
      AppThemeMode.dark => Brightness.dark,
      AppThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode == AppThemeMode.system
          ? ThemeMode.system
          : (themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light),
      routerConfig: router,
      builder: (context, child) {
        // Force brightness when not system
        if (themeMode != AppThemeMode.system) {
          return Theme(
            data: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
            child: child ?? const SizedBox.shrink(),
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
