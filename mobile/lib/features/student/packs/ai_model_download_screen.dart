import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Téléchargement et gestion des modèles IA embarqués.
class AiModelDownloadScreen extends StatelessWidget {
  const AiModelDownloadScreen({super.key});

  String _stageLabel(ModelDownloadStage stage) => switch (stage) {
        ModelDownloadStage.idle => 'Non installé',
        ModelDownloadStage.downloading => 'Téléchargement',
        ModelDownloadStage.verifyingSha256 => 'Vérification SHA256',
        ModelDownloadStage.decompressing => 'Décompression',
        ModelDownloadStage.installing => 'Installation',
        ModelDownloadStage.optimizing => 'Optimisation',
        ModelDownloadStage.completed => 'Terminé',
        ModelDownloadStage.error => 'Erreur',
      };

  int _stageIndex(ModelDownloadStage stage) => switch (stage) {
        ModelDownloadStage.idle => 0,
        ModelDownloadStage.downloading => 0,
        ModelDownloadStage.verifyingSha256 => 1,
        ModelDownloadStage.decompressing => 2,
        ModelDownloadStage.installing => 3,
        ModelDownloadStage.optimizing => 4,
        ModelDownloadStage.completed => 5,
        ModelDownloadStage.error => 0,
      };

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Téléchargement',
      'SHA256',
      'Décompression',
      'Installation',
      'Optimisation',
      'Terminé',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Modèles IA')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.aiModels.length,
        itemBuilder: (context, index) {
          final model = MockData.aiModels[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.memory, color: AppColors.electricBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(model.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${model.sizeMb.round()} Mo • RAM min. ${model.ramRequiredMb} Mo',
                              style: const TextStyle(fontSize: 13, color: AppColors.darkGray),
                            ),
                          ],
                        ),
                      ),
                      if (model.isInstalled)
                        const Icon(Icons.check_circle, color: AppColors.emeraldGreen),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_stageLabel(model.stage), style: const TextStyle(color: AppColors.darkGray)),
                  if (model.stage != ModelDownloadStage.idle &&
                      model.stage != ModelDownloadStage.completed) ...[
                    const SizedBox(height: 12),
                    StepIndicator(steps: steps, currentIndex: _stageIndex(model.stage)),
                    const SizedBox(height: 12),
                    ProgressBar(progress: model.progress),
                    if (model.downloadSpeedKbps != null)
                      Text(
                        '${model.downloadSpeedKbps!.round()} Ko/s',
                        style: const TextStyle(fontSize: 12, color: AppColors.darkGray),
                      ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (model.stage == ModelDownloadStage.idle)
                        Expanded(
                          child: FilledButton(
                            onPressed: () {},
                            child: const Text('Télécharger'),
                          ),
                        ),
                      if (model.stage == ModelDownloadStage.downloading) ...[
                        Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Suspendre'))),
                        const SizedBox(width: 8),
                        Expanded(child: FilledButton(onPressed: () {}, child: const Text('Reprendre'))),
                      ],
                      if (model.isInstalled)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Supprimer', style: TextStyle(color: AppColors.errorRed)),
                          ),
                        ),
                    ],
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
