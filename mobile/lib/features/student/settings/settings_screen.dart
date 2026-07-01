import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';

/// Paramètres élève — langue, thème, stockage, confidentialité.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          const _SectionTitle('Général'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Langue'),
            subtitle: const Text('Français'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Thème'),
            subtitle: Text(themeMode.name),
            trailing: DropdownButton<AppThemeMode>(
              value: themeMode,
              underline: const SizedBox(),
              items: AppThemeMode.values
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) ref.read(themeModeProvider.notifier).setTheme(v);
              },
            ),
          ),
          const _SectionTitle('Stockage & Téléchargements'),
          SwitchListTile(
            secondary: const Icon(Icons.wifi),
            title: const Text('Wi-Fi uniquement'),
            subtitle: const Text('Télécharger les packs uniquement en Wi-Fi'),
            value: true,
            onChanged: (_) {},
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Gérer le stockage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const _SectionTitle('Données & Confidentialité'),
          SwitchListTile(
            secondary: const Icon(Icons.backup),
            title: const Text('Sauvegarde locale'),
            subtitle: const Text('Sauvegarder progression sur l\'appareil'),
            value: true,
            onChanged: (_) {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Confidentialité'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Permissions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const _SectionTitle('À propos'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('MBOA MENCH v1.0.0'),
            subtitle: Text('L\'École dans la poche'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.electricBlue,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
