import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/account_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Paramètres enseignant — compte SQLite.
class TeacherSettingsScreen extends ConsumerWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(currentAccountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: accountAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (account) {
          return ListView(
            children: [
              if (account != null)
                ListTile(
                  leading: AvatarCircle(initials: account.avatarInitials, size: 40),
                  title: Text(account.name),
                  subtitle: Text(
                    account.school.isNotEmpty
                        ? account.school
                        : account.identifier,
                  ),
                )
              else
                const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Aucun compte connecté'),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Thème'),
                trailing: DropdownButton<AppThemeMode>(
                  value: ref.watch(themeModeProvider),
                  underline: const SizedBox(),
                  items: AppThemeMode.values
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) ref.read(themeModeProvider.notifier).setTheme(v);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.wifi_tethering),
                title: const Text('Réseau local'),
                onTap: () => context.push('/teacher/offline-classroom'),
              ),
              const ListTile(
                leading: Icon(Icons.memory),
                title: Text('Modèles IA installés'),
              ),
              const ListTile(
                leading: Icon(Icons.security),
                title: Text('Sécurité & Confidentialité'),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.errorRed),
                title: const Text('Déconnexion', style: TextStyle(color: AppColors.errorRed)),
                onTap: () async {
                  await ref.read(sessionProvider.notifier).logout();
                  if (context.mounted) context.go('/auth/role');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
