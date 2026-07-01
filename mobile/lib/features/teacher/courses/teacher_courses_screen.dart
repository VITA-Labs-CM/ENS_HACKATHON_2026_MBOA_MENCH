import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Gestion des cours enseignant.
class TeacherCoursesScreen extends StatelessWidget {
  const TeacherCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Cours'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.teacherCourses.length,
        itemBuilder: (context, index) {
          final c = MockData.teacherCourses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      StatusChip(
                        label: c.isPublished ? 'Publié' : 'Brouillon',
                        color: c.isPublished ? AppColors.emeraldGreen : AppColors.accentOrange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(c.description, style: TextStyle(color: AppColors.darkGray)),
                  const SizedBox(height: 8),
                  Text('${c.subject} • ${c.chapter} • ${c.durationMinutes} min'),
                  Wrap(
                    spacing: 6,
                    children: c.competencies
                        .map((comp) => Chip(label: Text(comp, style: const TextStyle(fontSize: 11))))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton(onPressed: () {}, child: const Text('Modifier')),
                      const SizedBox(width: 8),
                      if (!c.isPublished)
                        FilledButton(onPressed: () {}, child: const Text('Publier')),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Nouveau cours'),
      ),
    );
  }
}
