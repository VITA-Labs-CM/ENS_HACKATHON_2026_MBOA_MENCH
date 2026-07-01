import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Tableau de bord élève — accueil personnalisé.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = MockData.student;
    final currentSubject = MockData.subjects.first;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientCard(
              child: Row(
                children: [
                  AvatarCircle(initials: profile.avatarInitials, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, ${profile.name.split(' ').first} !',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${profile.level} • ${profile.className}',
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
                      'Niv. ${profile.levelNumber}',
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
                    value: '${(profile.overallProgress * 100).round()} %',
                    icon: Icons.trending_up,
                    color: AppColors.emeraldGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: "Aujourd'hui",
                    value: '${profile.studyMinutesToday} min',
                    icon: Icons.timer_outlined,
                    color: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Matière en cours'),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(currentSubject.color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.functions, color: Color(currentSubject.color)),
                ),
                title: Text(currentSubject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ProgressBar(progress: currentSubject.progress),
                ),
                trailing: FilledButton(
                  onPressed: () => context.go('/student/courses/${currentSubject.id}'),
                  child: const Text('Continuer'),
                ),
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
                          const Text(
                            'Obtenir 80 % au quiz Probabilités',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Débloquer le chapitre suivant',
                            style: TextStyle(color: AppColors.darkGray, fontSize: 13),
                          ),
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
