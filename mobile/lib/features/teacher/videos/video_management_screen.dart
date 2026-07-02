import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Gestion des vidéos pédagogiques.
class VideoManagementScreen extends StatelessWidget {
  const VideoManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vidéos'),
        actions: [IconButton(icon: const Icon(Icons.videocam), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _VideoCard(
            title: 'Introduction aux nombres complexes',
            duration: '12:34',
            views: 42,
            progress: 0.78,
          ),
          const _VideoCard(
            title: 'Suites arithmétiques — Méthode',
            duration: '18:20',
            views: 28,
            progress: 0.55,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              ActionChip(label: const Text('Téléverser'), avatar: const Icon(Icons.upload, size: 18), onPressed: () {}),
              ActionChip(label: const Text('Enregistrer'), avatar: const Icon(Icons.videocam, size: 18), onPressed: () {}),
              ActionChip(label: const Text('Découper'), avatar: const Icon(Icons.content_cut, size: 18), onPressed: () {}),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une vidéo'),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.title,
    required this.duration,
    required this.views,
    required this.progress,
  });

  final String title;
  final String duration;
  final int views;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.darkBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_fill, size: 56, color: Colors.white54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$duration • $views vues • Progression moy. ${(progress * 100).round()} %'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Miniature')),
                    TextButton(onPressed: () {}, child: const Text('Sous-titres')),
                    TextButton(onPressed: () {}, child: const Text('Associer')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
