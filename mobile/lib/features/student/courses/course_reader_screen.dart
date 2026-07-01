import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';

/// Lecteur de cours — texte riche, taille police, mode lecture.
class CourseReaderScreen extends StatefulWidget {
  const CourseReaderScreen({super.key, required this.chapterId});

  final String chapterId;

  @override
  State<CourseReaderScreen> createState() => _CourseReaderScreenState();
}

class _CourseReaderScreenState extends State<CourseReaderScreen> {
  double _fontSize = 16;
  bool _readingMode = false;

  @override
  Widget build(BuildContext context) {
    final content = MockData.courseContent(widget.chapterId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(content.title, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(_readingMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _readingMode = !_readingMode),
            tooltip: 'Mode lecture',
          ),
          PopupMenuButton<double>(
            icon: const Icon(Icons.text_fields),
            onSelected: (v) => setState(() => _fontSize = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 14.0, child: Text('Petit')),
              const PopupMenuItem(value: 16.0, child: Text('Normal')),
              const PopupMenuItem(value: 18.0, child: Text('Grand')),
              const PopupMenuItem(value: 22.0, child: Text('Très grand')),
            ],
          ),
        ],
      ),
      backgroundColor: _readingMode
          ? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF8E7))
          : null,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: content.sections.length,
              itemBuilder: (_, i) {
                final section = content.sections[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: TextStyle(
                          fontSize: _fontSize + 4,
                          fontWeight: FontWeight.bold,
                          color: AppColors.electricBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (section.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(section.imageUrl!, height: 180, fit: BoxFit.cover),
                        ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _readingMode
                              ? Colors.transparent
                              : AppColors.electricBlue.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          section.body,
                          style: TextStyle(fontSize: _fontSize, height: 1.7),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Précédent'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/student/chapter/${widget.chapterId}/quiz'),
                    icon: const Icon(Icons.quiz),
                    label: const Text('Quiz'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.emeraldGreen),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
