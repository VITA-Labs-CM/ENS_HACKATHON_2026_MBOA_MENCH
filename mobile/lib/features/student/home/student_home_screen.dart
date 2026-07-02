import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/account_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Tableau de bord élève — données du compte SQLite.
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(currentAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/student/notifications'),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientCard(
                  child: Row(
                    children: [
                      AvatarCircle(initials: account.avatarInitials, size: 56),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, ${account.firstName} !',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              [
                                if (account.level.isNotEmpty) account.level,
                                if (account.className.isNotEmpty) account.className,
                              ].join(' • '),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Niv. ${account.levelNumber}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Progression',
                        value: '${(account.overallProgress * 100).round()} %',
                        icon: Icons.trending_up,
                        color: AppColors.emeraldGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: "Aujourd'hui",
                        value: '${account.studyMinutesToday} min',
                        icon: Icons.timer_outlined,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Établissement'),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.school, color: AppColors.electricBlue),
                    title: Text(
                      account.school.isNotEmpty ? account.school : 'Non renseigné',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: account.className.isNotEmpty
                        ? Text(account.className)
                        : const Text('Complétez votre profil dans les paramètres'),
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Prochain objectif'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_rounded, color: AppColors.accentOrange, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.overallProgress >= 0.8
                                    ? 'Continuez sur cette lancée !'
                                    : 'Atteindre 80 % de progression globale',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              ProgressBar(progress: account.overallProgress),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Accès rapide'),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickAction(
                      icon: Icons.download_rounded,
                      label: 'Packs',
                      color: AppColors.electricBlue,
                      onTap: () => context.push('/student/packs'),
                    ),
                    _QuickAction(
                      icon: Icons.memory_rounded,
                      label: 'Modèles IA',
                      color: AppColors.emeraldGreen,
                      onTap: () => context.push('/student/ai-models'),
                    ),
                    _QuickAction(
                      icon: Icons.psychology_rounded,
                      label: 'Assistant',
                      color: AppColors.accentOrange,
                      onTap: () => context.go('/student/ai'),
                    ),
                    _QuickAction(
                      icon: Icons.settings_rounded,
                      label: 'Paramètres',
                      color: AppColors.darkGray,
                      onTap: () => context.push('/student/settings'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.sizeOf(context).width - 56) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
