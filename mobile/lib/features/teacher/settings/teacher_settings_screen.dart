import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';

/// Paramètres enseignant.
class TeacherSettingsScreen extends ConsumerWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Prof. Jean-Baptiste Mballa'),
            subtitle: Text('Lycée Bilingue de Maroua'),
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
          ListTile(leading: const Icon(Icons.wifi_tethering), title: const Text('Réseau local'), onTap: () => context.push('/teacher/offline-classroom')),
          ListTile(leading: const Icon(Icons.memory), title: const Text('Modèles IA installés'), onTap: () {}),
          ListTile(leading: const Icon(Icons.security), title: const Text('Sécurité & Confidentialité'), onTap: () {}),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorRed),
            title: const Text('Déconnexion', style: TextStyle(color: AppColors.errorRed)),
            onTap: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (context.mounted) context.go('/auth/role');
            },
          ),
        ],
      ),
    );
  }
}
