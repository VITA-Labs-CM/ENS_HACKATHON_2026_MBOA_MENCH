import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Dashboard enseignant — stats, activités, navigation rapide.
class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cols = responsiveCrossAxisCount(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/teacher/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, Prof. Mballa',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lycée Bilingue de Maroua',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => context.push('/teacher/ai-content'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.electricBlue),
                    child: const Text('Créer un cours'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: const [
                StatCard(label: 'Cours actifs', value: '12', icon: Icons.menu_book, color: AppColors.electricBlue),
                StatCard(label: 'Classes', value: '3', icon: Icons.class_, color: AppColors.emeraldGreen),
                StatCard(label: 'Élèves', value: '135', icon: Icons.people, color: AppColors.accentOrange),
                StatCard(label: 'Progression moy.', value: '68 %', icon: Icons.trending_up, color: AppColors.electricBlue),
                StatCard(label: 'Ressources', value: '47', icon: Icons.folder, color: AppColors.emeraldGreen),
                StatCard(label: 'Tickets', value: '1', icon: Icons.support, color: AppColors.errorRed),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Progression par classe'),
            SizedBox(
              height: 200,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barGroups: [
                        _bar(0, 78, 'Tle D'),
                        _bar(1, 65, 'Proba C'),
                        _bar(2, 52, '3e F'),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const labels = ['Tle D', 'Proba C', '3e F'];
                              return Text(labels[v.toInt()], style: const TextStyle(fontSize: 11));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Activités récentes', actionLabel: 'Voir tout', onAction: () {}),
            ...MockData.recentActivities.map((a) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
                      child: const Icon(Icons.notifications, color: AppColors.electricBlue, size: 20),
                    ),
                    title: Text(a.title),
                    subtitle: Text(a.subtitle),
                  ),
                )),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _NavChip('Export Pack', Icons.archive, () => context.push('/teacher/pack-export')),
                _NavChip('Salle locale', Icons.wifi_tethering, () => context.push('/teacher/offline-classroom')),
                _NavChip('Analyse IA', Icons.analytics, () => context.push('/teacher/analytics')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, String _) => BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            color: AppColors.emeraldGreen,
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
}

class _NavChip extends StatelessWidget {
  const _NavChip(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.electricBlue),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
