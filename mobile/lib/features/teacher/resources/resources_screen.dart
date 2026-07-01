import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Ressources pédagogiques — import PDF, DOCX, etc.
class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ressources'),
        actions: [IconButton(icon: const Icon(Icons.upload_file), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Zone drag & drop sur desktop
          if (MediaQuery.sizeOf(context).width >= 768)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.electricBlue, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.electricBlue.withValues(alpha: 0.04),
              ),
              child: const Column(
                children: [
                  Icon(Icons.cloud_upload, size: 48, color: AppColors.electricBlue),
                  SizedBox(height: 12),
                  Text('Glissez-déposez vos fichiers ici'),
                  Text('PDF, DOCX, PPTX, Images, Vidéos, Audio', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MockData.resources.length,
              itemBuilder: (context, index) {
                final r = MockData.resources[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(_iconForType(r.type), color: AppColors.electricBlue),
                    title: Text(r.name),
                    subtitle: Text('${r.type} • ${r.sizeMb} Mo • ${r.pageCount} pages\n${r.analysisStatus}'),
                    isThreeLine: true,
                    trailing: StatusChip(
                      label: r.isValidated ? 'Validé' : 'En attente',
                      color: r.isValidated ? AppColors.emeraldGreen : AppColors.accentOrange,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Importer'),
      ),
    );
  }

  IconData _iconForType(String type) => switch (type) {
        'PDF' => Icons.picture_as_pdf,
        'DOCX' => Icons.description,
        _ => Icons.insert_drive_file,
      };
}
