import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/account_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Profil élève — données du compte SQLite.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(currentAccountProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/student/settings'),
          ),
        ],
      ),
      body: accountAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (account) {
          if (account == null) {
            return const Center(child: Text('Aucun compte connecté.'));
          }

          final storagePct = account.storageTotalMb > 0
              ? account.storageUsedMb / account.storageTotalMb
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        AvatarCircle(initials: account.avatarInitials, size: 80),
                        const SizedBox(height: 16),
                        Text(
                          account.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (account.school.isNotEmpty)
                          Text(account.school, style: const TextStyle(color: AppColors.darkGray)),
                        if (account.className.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          StatusChip(label: account.className, color: AppColors.electricBlue),
                        ],
                        if (account.level.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(account.level, style: const TextStyle(color: AppColors.darkGray)),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          account.identifier,
                          style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _ProfileTile(
                  icon: Icons.language,
                  title: 'Langue',
                  subtitle: 'Français',
                  onTap: () {},
                ),
                _ProfileTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Thème',
                  subtitle: themeMode.name,
                  trailing: Switch(
                    value: themeMode == AppThemeMode.dark,
                    onChanged: (v) => ref.read(themeModeProvider.notifier).setTheme(
                          v ? AppThemeMode.dark : AppThemeMode.light,
                        ),
                  ),
                ),
                _ProfileTile(
                  icon: Icons.storage,
                  title: 'Stockage utilisé',
                  subtitle: '${account.storageUsedMb.round()} Mo / ${account.storageTotalMb.round()} Mo',
                  onTap: () => context.push('/student/packs'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ProgressBar(progress: storagePct, color: AppColors.accentOrange),
                ),
                _ProfileTile(
                  icon: Icons.download_rounded,
                  title: 'Packs & Modèles IA',
                  onTap: () => context.push('/student/packs'),
                ),
                const _ProfileTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  subtitle: AppConstants.appVersion,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(sessionProvider.notifier).logout();
                    if (context.mounted) context.go('/auth/role');
                  },
                  icon: const Icon(Icons.logout, color: AppColors.errorRed),
                  label: const Text('Déconnexion', style: TextStyle(color: AppColors.errorRed)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.electricBlue),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
