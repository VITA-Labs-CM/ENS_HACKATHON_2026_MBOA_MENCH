import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Bibliothèque pédagogique — recherche, filtres, favoris.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bibliothèque')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(hint: 'Rechercher un ouvrage...'),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Tous', 'Maths', 'Physique', 'Français', 'Validés', 'Favoris']
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(label: Text(f), selected: f == 'Tous', onSelected: (_) {}),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.menu_book, color: AppColors.electricBlue),
                  ),
                  title: Text('Manuel ${index + 1} — MINESEC'),
                  subtitle: const Text('Mathématiques • Terminale • Validé'),
                  trailing: const Icon(Icons.favorite_border),
                  onTap: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
