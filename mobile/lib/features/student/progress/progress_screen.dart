import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Écran progression — stats, XP, badges, graphique, calendrier.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = MockData.student;

    return Scaffold(
      appBar: AppBar(title: const Text('Ma Progression')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _XpStat(label: 'XP', value: '${profile.xp}'),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _XpStat(label: 'Niveau', value: '${profile.levelNumber}'),
                  Container(width: 1, height: 40, color: Colors.white30),
                  _XpStat(label: 'Badges', value: '${MockData.badges.where((b) => b.isUnlocked).length}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'XP — 7 derniers jours'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 300,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                              return Text(days[v.toInt() % 7], style: const TextStyle(fontSize: 12));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        MockData.weeklyXp.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: MockData.weeklyXp[i].toDouble(),
                              color: AppColors.electricBlue,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Compétences APC'),
            ...MockData.skills.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProgressBar(progress: s.$2, label: s.$1),
                )),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Badges'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: MockData.badges.map((b) {
                return Container(
                  width: (MediaQuery.sizeOf(context).width - 56) / 2,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: b.isUnlocked
                        ? AppColors.emeraldGreen.withValues(alpha: 0.08)
                        : AppColors.mediumGray.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: b.isUnlocked
                          ? AppColors.emeraldGreen.withValues(alpha: 0.3)
                          : AppColors.mediumGray.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(b.icon, style: TextStyle(fontSize: 32, color: b.isUnlocked ? null : Colors.grey)),
                      const SizedBox(height: 8),
                      Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      Text(b.description, style: TextStyle(fontSize: 11, color: AppColors.darkGray), textAlign: TextAlign.center),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Calendrier d\'étude'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final studied = i != 2 && i != 5;
                    return Column(
                      children: [
                        Text(['L', 'M', 'M', 'J', 'V', 'S', 'D'][i]),
                        const SizedBox(height: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: studied
                                ? AppColors.emeraldGreen
                                : AppColors.mediumGray.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: studied
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
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
