import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Assistant export de packs éducatifs sécurisés.
class PackExportScreen extends StatefulWidget {
  const PackExportScreen({super.key});

  @override
  State<PackExportScreen> createState() => _PackExportScreenState();
}

class _PackExportScreenState extends State<PackExportScreen> {
  int _step = 0;
  bool _exporting = false;

  static const _steps = [
    'Préparation',
    'Vérification',
    'Compression',
    'Signature',
    'Génération',
    'Export',
  ];

  Future<void> _startExport() async {
    setState(() => _exporting = true);
    for (var i = 0; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _step = i);
    }
    setState(() => _exporting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Pack Éducatif')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Contenu du pack'),
            ...['Cours validés', 'PDF & Word', 'Quiz & Examens', 'Ressources', 'Métadonnées MINESEC']
                .map((item) => CheckboxListTile(
                      value: true,
                      onChanged: (_) {},
                      title: Text(item),
                      controlAffinity: ListTileControlAffinity.leading,
                    )),
            const SizedBox(height: 24),
            StepIndicator(steps: _steps, currentIndex: _step),
            const SizedBox(height: 24),
            if (_step >= 5)
              Card(
                color: AppColors.emeraldGreen.withValues(alpha: 0.1),
                child: const ListTile(
                  leading: Icon(Icons.check_circle, color: AppColors.emeraldGreen),
                  title: Text('Pack généré avec succès !'),
                  subtitle: Text('Pack_Maths_TleD_v1.0.mboa — 245 Mo — Signé'),
                ),
              ),
            const SizedBox(height: 24),
            LoadingButton(
              label: _step >= 5 ? 'Partager le pack' : 'Générer le pack',
              icon: Icons.archive,
              isLoading: _exporting,
              onPressed: _step >= 5 ? () {} : _startExport,
            ),
            if (_step >= 5) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.bluetooth),
                label: const Text('Distribuer via Bluetooth / USB'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
