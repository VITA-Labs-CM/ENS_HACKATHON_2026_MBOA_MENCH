import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/providers/account_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Gestionnaire de téléchargement des packs pédagogiques.
class PackDownloadScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(currentAccountProvider);
    const steps = ['Téléchargement', 'Vérification', 'Installation', 'Indexation', 'Terminé'];

    return Scaffold(
      appBar: AppBar(title: const Text('Packs pédagogiques')),
      body: accountAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (account) {
          if (account == null) {
            return const Center(child: Text('Aucun compte connecté.'));
          }

          final freeMb = account.storageTotalMb - account.storageUsedMb;
          final storageProgress = account.storageTotalMb > 0
              ? account.storageUsedMb / account.storageTotalMb
              : 0.0;

          return SingleChildScrollView(
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
                          progress: storageProgress,
                          label: '${freeMb.round()} Mo libres',
                          color: AppColors.emeraldGreen,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.wifi, size: 16, color: AppColors.emeraldGreen),
                    SizedBox(width: 8),
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
                                    Text('${pack.subject} • ${pack.level}'),
                                  ],
                                ),
                              ),
                              Text('${pack.sizeMb.round()} Mo'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (pack.stage != PackDownloadStage.idle &&
                              pack.stage != PackDownloadStage.completed)
                            Column(
                              children: [
                                LinearProgressIndicator(value: pack.progress),
                                const SizedBox(height: 8),
                                Text(
                                  '${_stageLabel(pack.stage)} — ${(pack.progress * 100).round()} %',
                                  style: const TextStyle(fontSize: 12, color: AppColors.darkGray),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(steps.length, (i) {
                                    final active = i <= _stageIndex(pack.stage);
                                    return Expanded(
                                      child: Column(
                                        children: [
                                          Icon(
                                            active ? Icons.check_circle : Icons.circle_outlined,
                                            size: 16,
                                            color: active ? AppColors.emeraldGreen : AppColors.mediumGray,
                                          ),
                                          Text(
                                            steps[i],
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: active ? AppColors.emeraldGreen : AppColors.mediumGray,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          if (pack.stage == PackDownloadStage.completed)
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.emeraldGreen, size: 18),
                                SizedBox(width: 8),
                                Text('Installé', style: TextStyle(color: AppColors.emeraldGreen)),
                              ],
                            ),
                          if (pack.stage == PackDownloadStage.idle)
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.download),
                                label: const Text('Télécharger'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
