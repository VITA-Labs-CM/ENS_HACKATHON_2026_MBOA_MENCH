import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Validation des livres du programme MINESEC/MINESUP.
class BookValidationScreen extends StatelessWidget {
  const BookValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validation livres MINESEC')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.proposedBooks.length,
        itemBuilder: (context, index) {
          final book = MockData.proposedBooks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.menu_book, size: 40, color: AppColors.electricBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${book.author} • ${book.subject}'),
                            Text('${book.level} — ${book.program}'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                StatusChip(
                                  label: 'Confiance ${(book.confidenceScore * 100).round()} %',
                                  color: AppColors.emeraldGreen,
                                ),
                                const SizedBox(width: 8),
                                StatusChip(
                                  label: 'Programme ${(book.programMatch * 100).round()} %',
                                  color: AppColors.electricBlue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(book.summary),
                  Text('Source : ${book.source}', style: const TextStyle(fontSize: 12, color: AppColors.darkGray)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check),
                          label: const Text('Approuver'),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.emeraldGreen),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Rejeter'),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                    label: const Text('Demander une réanalyse'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
