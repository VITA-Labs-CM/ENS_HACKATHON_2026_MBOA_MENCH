import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Gestion des élèves — progression, statuts, difficultés.
class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  Color _statusColor(StudentStatus s) => switch (s) {
        StudentStatus.onTrack => AppColors.emeraldGreen,
        StudentStatus.behind => AppColors.accentOrange,
        StudentStatus.struggling => AppColors.errorRed,
      };

  String _statusLabel(StudentStatus s) => switch (s) {
        StudentStatus.onTrack => 'À jour',
        StudentStatus.behind => 'En retard',
        StudentStatus.struggling => 'En difficulté',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Élèves'),
        actions: [IconButton(icon: const Icon(Icons.filter_list), onPressed: () {})],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: SearchField(hint: 'Rechercher un élève...'),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: MockData.classStudents.length,
              itemBuilder: (context, index) {
                final s = MockData.classStudents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    leading: AvatarCircle(initials: s.name.split(' ').map((w) => w[0]).take(2).join(), size: 40),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: StatusChip(label: _statusLabel(s.status), color: _statusColor(s.status)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ProgressBar(progress: s.progress, label: 'Progression'),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _Stat('Quiz moy.', '${s.quizAverage} %'),
                                _Stat('Modules', '${s.modulesCompleted}'),
                                _Stat('Badges', '${s.badges}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.darkGray)),
      ],
    );
  }
}
