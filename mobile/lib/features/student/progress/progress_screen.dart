import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/account_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Écran progression — stats du compte SQLite.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(currentAccountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ma Progression')),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _XpStat(label: 'XP', value: '${account.xp}'),
                      Container(width: 1, height: 40, color: Colors.white30),
                      _XpStat(label: 'Niveau', value: '${account.levelNumber}'),
                      Container(width: 1, height: 40, color: Colors.white30),
                      _XpStat(
                        label: 'Progression',
                        value: '${(account.overallProgress * 100).round()} %',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Activité'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _StatRow(
                          icon: Icons.timer_outlined,
                          label: "Temps d'étude aujourd'hui",
                          value: '${account.studyMinutesToday} min',
                        ),
                        const Divider(height: 24),
                        _StatRow(
                          icon: Icons.trending_up,
                          label: 'Progression globale',
                          value: '${(account.overallProgress * 100).round()} %',
                        ),
                        const SizedBox(height: 12),
                        ProgressBar(progress: account.overallProgress),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Profil scolaire'),
                Card(
                  child: Column(
                    children: [
                      if (account.school.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.school, color: AppColors.electricBlue),
                          title: const Text('Établissement'),
                          subtitle: Text(account.school),
                        ),
                      if (account.className.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.class_outlined, color: AppColors.emeraldGreen),
                          title: const Text('Classe'),
                          subtitle: Text(account.className),
                        ),
                      if (account.level.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.stairs, color: AppColors.accentOrange),
                          title: const Text('Niveau'),
                          subtitle: Text(account.level),
                        ),
                      if (account.school.isEmpty &&
                          account.className.isEmpty &&
                          account.level.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Complétez votre profil pour suivre votre progression scolaire.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.darkGray),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Stockage'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${account.storageUsedMb.round()} Mo / ${account.storageTotalMb.round()} Mo utilisés',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ProgressBar(
                          progress: account.storageTotalMb > 0
                              ? account.storageUsedMb / account.storageTotalMb
                              : 0,
                          color: AppColors.accentOrange,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _XpStat extends StatelessWidget {
  const _XpStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.electricBlue),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
