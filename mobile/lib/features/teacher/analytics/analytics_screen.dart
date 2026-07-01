import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Analyse pédagogique par IA — recommandations et prédictions.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analyse IA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Vue d\'ensemble'),
            GridView.count(
              crossAxisCount: responsiveCrossAxisCount(context),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: const [
                StatCard(label: 'Taux réussite', value: '72 %', icon: Icons.check_circle, color: AppColors.emeraldGreen),
                StatCard(label: 'Temps moyen', value: '38 min/j', icon: Icons.timer, color: AppColors.accentOrange),
                StatCard(label: 'En difficulté', value: '8', icon: Icons.warning, color: AppColors.errorRed),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Compétences non acquises'),
            ...MockData.skills.where((s) => s.$2 < 0.7).map((s) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.error_outline, color: AppColors.accentOrange),
                    title: Text(s.$1),
                    subtitle: ProgressBar(progress: s.$2),
                  ),
                )),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Recommandations IA'),
            Card(
              color: AppColors.electricBlue.withValues(alpha: 0.06),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.electricBlue),
                        SizedBox(width: 8),
                        Text('Suggestions pédagogiques', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text('• 8 élèves ont des difficultés en « Modélisation » — proposer un module de renforcement'),
                    Text('• Ibrahim Abba n\'a pas progressé depuis 4 jours — envoyer un rappel'),
                    Text('• Le chapitre « Probabilités » a un taux d\'échec élevé — revoir les exercices'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Progression par matière'),
            SizedBox(
              height: 200,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(value: 35, title: 'Maths', color: AppColors.electricBlue, radius: 60),
                        PieChartSectionData(value: 25, title: 'Physique', color: AppColors.emeraldGreen, radius: 55),
                        PieChartSectionData(value: 20, title: 'Français', color: AppColors.accentOrange, radius: 50),
                        PieChartSectionData(value: 20, title: 'Autres', color: AppColors.mediumGray, radius: 45),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
