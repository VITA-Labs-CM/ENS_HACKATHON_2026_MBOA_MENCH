import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/providers/account_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Dashboard enseignant — stats, activités, navigation rapide.
class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(currentAccountProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Espace Enseignant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            accountAsync.when(
              loading: () => const _HeroHeader.loading(),
              error: (_, __) => const _HeroHeader.error(),
              data: (account) => _HeroHeader(
                teacherName: account?.name ?? 'Enseignant',
                schoolName: account?.school.isNotEmpty == true
                    ? account!.school
                    : (account?.identifier ?? 'Compte local'),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 980;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _PrimaryColumn(
                          onCreateContent: () => context.push('/teacher/ai-content'),
                          onManageClasses: () => context.push('/teacher/classes'),
                          onOpenCourses: () => context.push('/teacher/courses-list'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SideColumn(
                          onOpenAnalytics: () => context.push('/teacher/analytics'),
                          onOpenTickets: () => context.push('/teacher/tickets'),
                          onOpenResources: () => context.push('/teacher/resources'),
                          onOpenLocalClassroom: () => context.push('/teacher/offline-classroom'),
                          onOpenPackExport: () => context.push('/teacher/pack-export'),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _PrimaryColumn(
                      onCreateContent: () => context.push('/teacher/ai-content'),
                      onManageClasses: () => context.push('/teacher/classes'),
                      onOpenCourses: () => context.push('/teacher/courses-list'),
                    ),
                    const SizedBox(height: 16),
                    _SideColumn(
                      onOpenAnalytics: () => context.push('/teacher/analytics'),
                      onOpenTickets: () => context.push('/teacher/tickets'),
                      onOpenResources: () => context.push('/teacher/resources'),
                      onOpenLocalClassroom: () => context.push('/teacher/offline-classroom'),
                      onOpenPackExport: () => context.push('/teacher/pack-export'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.teacherName,
    required this.schoolName,
  });

  const _HeroHeader.loading()
      : teacherName = '',
        schoolName = '';

  const _HeroHeader.error()
      : teacherName = 'Compte indisponible',
        schoolName = 'Impossible de charger les informations';

  final String teacherName;
  final String schoolName;

  @override
  Widget build(BuildContext context) {
    if (teacherName.isEmpty && schoolName.isEmpty) {
      return const GradientCard(
        child: SizedBox(
          height: 88,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, ${teacherName.split(' ').first}',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            schoolName,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderTag(icon: Icons.auto_awesome, label: 'Assisté par IA'),
              _HeaderTag(icon: Icons.cloud_done, label: 'Synchronisation prête'),
              _HeaderTag(icon: Icons.groups_2, label: 'Classe connectée'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  const _HeaderTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _PrimaryColumn extends StatelessWidget {
  const _PrimaryColumn({
    required this.onCreateContent,
    required this.onManageClasses,
    required this.onOpenCourses,
  });

  final VoidCallback onCreateContent;
  final VoidCallback onManageClasses;
  final VoidCallback onOpenCourses;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Espace de travail', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                const Text(
                  'Interface inspirée Classroom/NotebookLM: flux de classe, création guidée et priorités.',
                  style: TextStyle(color: AppColors.darkGray),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ActionPill(
                      label: 'Créer du contenu IA',
                      icon: Icons.auto_awesome,
                      color: AppColors.electricBlue,
                      onTap: onCreateContent,
                    ),
                    _ActionPill(
                      label: 'Gérer les classes',
                      icon: Icons.class_,
                      color: AppColors.emeraldGreen,
                      onTap: onManageClasses,
                    ),
                    _ActionPill(
                      label: 'Ouvrir mes cours',
                      icon: Icons.menu_book,
                      color: AppColors.accentOrange,
                      onTap: onOpenCourses,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Aperçu classes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      maxY: 100,
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(enabled: false),
                      barGroups: [
                        _ClassBar.group(0, 78),
                        _ClassBar.group(1, 65),
                        _ClassBar.group(2, 52),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              const labels = ['Tle D', 'Proba C', '3e F'];
                              return Text(labels[value.toInt()], style: const TextStyle(fontSize: 11));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        horizontalInterval: 25,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppColors.mediumGray.withValues(alpha: 0.18),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fil d’activité', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                ...MockData.recentActivities.take(4).map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.electricBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(activity.subtitle, style: const TextStyle(color: AppColors.darkGray, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn({
    required this.onOpenAnalytics,
    required this.onOpenTickets,
    required this.onOpenResources,
    required this.onOpenLocalClassroom,
    required this.onOpenPackExport,
  });

  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenTickets;
  final VoidCallback onOpenResources;
  final VoidCallback onOpenLocalClassroom;
  final VoidCallback onOpenPackExport;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Actions rapides', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                _QuickItem(icon: Icons.analytics, label: 'Analyse IA', subtitle: 'Tendances et alertes', onTap: onOpenAnalytics),
                _QuickItem(icon: Icons.support_agent, label: 'Tickets', subtitle: 'Support enseignant', onTap: onOpenTickets),
                _QuickItem(icon: Icons.folder, label: 'Ressources', subtitle: 'PDF, docs, médias', onTap: onOpenResources),
                _QuickItem(icon: Icons.wifi_tethering, label: 'Salle locale', subtitle: 'Mode classe offline', onTap: onOpenLocalClassroom),
                _QuickItem(icon: Icons.archive, label: 'Export Pack', subtitle: 'Distribuer hors ligne', onTap: onOpenPackExport),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assistant pédagogique', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                SizedBox(height: 10),
                _InsightLine('Chapitre "Probabilités" en baisse de réussite'),
                _InsightLine('3 élèves inactifs depuis 72h'),
                _InsightLine('Suggestion: quiz de remédiation ciblé'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _QuickItem extends StatelessWidget {
  const _QuickItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 10,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
        child: Icon(icon, size: 18, color: AppColors.electricBlue),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ClassBar {
  const _ClassBar._();

  static BarChartGroupData group(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 24,
          color: AppColors.electricBlue,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: AppColors.electricBlue.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}

class _InsightLine extends StatelessWidget {
  const _InsightLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.fiber_manual_record, size: 8, color: AppColors.darkGray),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.darkGray))),
        ],
      ),
    );
  }
}
