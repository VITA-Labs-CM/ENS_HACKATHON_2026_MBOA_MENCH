import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Liste des matières sous forme de cartes.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  IconData _iconFor(String iconName) => switch (iconName) {
        'functions' => Icons.functions,
        'science' => Icons.science,
        'menu_book' => Icons.menu_book,
        'public' => Icons.public,
        'eco' => Icons.eco,
        'translate' => Icons.translate,
        _ => Icons.book,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Cours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => context.push('/student/packs'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.subjects.length,
        itemBuilder: (context, index) {
          final subject = MockData.subjects[index];
          final color = Color(subject.color);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => context.push('/student/courses/${subject.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_iconFor(subject.icon), color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${subject.completedChapters}/${subject.chapterCount} chapitres',
                                style: TextStyle(color: AppColors.darkGray, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.mediumGray),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ProgressBar(progress: subject.progress, label: 'Progression'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/student/courses/${subject.id}'),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Continuer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
