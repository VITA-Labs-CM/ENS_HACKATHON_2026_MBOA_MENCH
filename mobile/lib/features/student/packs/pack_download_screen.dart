import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Gestionnaire de téléchargement des packs pédagogiques.
class PackDownloadScreen extends StatelessWidget {
  const PackDownloadScreen({super.key});

  String _stageLabel(PackDownloadStage stage) => switch (stage) {
        PackDownloadStage.idle => 'En attente',
        PackDownloadStage.downloading => 'Téléchargement',
        PackDownloadStage.verifying => 'Vérification',
        PackDownloadStage.installing => 'Installation',
        PackDownloadStage.indexing => 'Indexation',
        PackDownloadStage.completed => 'Terminé',
        PackDownloadStage.error => 'Erreur',
      };

  int _stageIndex(PackDownloadStage stage) => switch (stage) {
        PackDownloadStage.idle => 0,
        PackDownloadStage.downloading => 0,
        PackDownloadStage.verifying => 1,
        PackDownloadStage.installing => 2,
        PackDownloadStage.indexing => 3,
        PackDownloadStage.completed => 4,
        PackDownloadStage.error => 0,
      };

  @override
  Widget build(BuildContext context) {
    final profile = MockData.student;
    const steps = ['Téléchargement', 'Vérification', 'Installation', 'Indexation', 'Terminé'];

    return Scaffold(
      appBar: AppBar(title: const Text('Packs pédagogiques')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Espace disponible', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ProgressBar(
                      progress: profile.storageUsedMb / profile.storageTotalMb,
                      label: '${(profile.storageTotalMb - profile.storageUsedMb).round()} Mo libres',
                      color: AppColors.emeraldGreen,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.wifi, size: 16, color: AppColors.emeraldGreen),
                const SizedBox(width: 8),
                Text('Wi-Fi uniquement activé', style: TextStyle(color: AppColors.darkGray, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Packs disponibles'),
            ...MockData.eduPacks.map((pack) {
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pack.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${pack.subject} • ${pack.level} • ${pack.sizeMb.round()} Mo'),
                              ],
                            ),
                          ),
                          StatusChip(
                            label: _stageLabel(pack.stage),
                            color: pack.stage == PackDownloadStage.completed
                                ? AppColors.emeraldGreen
                                : AppColors.electricBlue,
                          ),
                        ],
                      ),
                      if (pack.stage != PackDownloadStage.idle &&
                          pack.stage != PackDownloadStage.completed) ...[
                        const SizedBox(height: 16),
                        StepIndicator(steps: steps, currentIndex: _stageIndex(pack.stage)),
                        const SizedBox(height: 12),
                        ProgressBar(progress: pack.progress),
                        if (pack.downloadSpeedKbps != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${pack.downloadSpeedKbps!.round()} Ko/s • ${(pack.progress * 100).round()} %',
                              style: TextStyle(fontSize: 12, color: AppColors.darkGray),
                            ),
                          ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (pack.stage == PackDownloadStage.idle)
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.download),
                                label: const Text('Télécharger'),
                              ),
                            ),
                          if (pack.stage == PackDownloadStage.downloading) ...[
                            Expanded(
                              child: OutlinedButton(onPressed: () {}, child: const Text('Suspendre')),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(onPressed: () {}, child: const Text('Reprendre')),
                            ),
                          ],
                          if (pack.stage == PackDownloadStage.completed)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                                label: const Text('Supprimer'),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bluetooth),
              label: const Text('Importer via Bluetooth / USB / SD'),
            ),
          ],
        ),
      ),
    );
  }
}
