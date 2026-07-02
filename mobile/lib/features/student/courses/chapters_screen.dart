import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Liste des chapitres avec verrouillage (80 % requis).
class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context) {
    final subject = MockData.subjects.firstWhere((s) => s.id == subjectId);
    final chapters = MockData.chaptersFor(subjectId);

    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final ch = chapters[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: ch.isCompleted
                    ? AppColors.emeraldGreen
                    : ch.isLocked
                        ? AppColors.mediumGray.withValues(alpha: 0.3)
                        : AppColors.electricBlue.withValues(alpha: 0.12),
                child: Icon(
                  ch.isCompleted
                      ? Icons.check
                      : ch.isLocked
                          ? Icons.lock
                          : Icons.play_arrow,
                  color: ch.isCompleted
                      ? Colors.white
                      : ch.isLocked
                          ? AppColors.mediumGray
                          : AppColors.electricBlue,
                ),
              ),
              title: Text(
                'Ch. ${ch.order} — ${ch.title}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ch.isLocked ? AppColors.mediumGray : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('~${ch.estimatedMinutes} min'),
                  if (ch.lastScore != null)
                    Text(
                      'Score : ${ch.lastScore} %',
                      style: TextStyle(
                        color: ch.lastScore! >= AppConstants.chapterUnlockScore
                            ? AppColors.emeraldGreen
                            : AppColors.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (ch.isLocked)
                    const Text(
                      'Score ≥ ${AppConstants.chapterUnlockScore} % requis',
                      style: TextStyle(color: AppColors.errorRed, fontSize: 12),
                    ),
                  if (!ch.isLocked && !ch.isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ProgressBar(progress: ch.progress, height: 4),
                    ),
                ],
              ),
              trailing: ch.isLocked
                  ? null
                  : FilledButton(
                      onPressed: () => context.push('/student/chapter/${ch.id}/read'),
                      child: Text(ch.isCompleted ? 'Revoir' : 'Commencer'),
                    ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
