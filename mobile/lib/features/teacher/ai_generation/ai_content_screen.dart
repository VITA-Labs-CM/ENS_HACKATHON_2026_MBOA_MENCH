import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Génération de contenus avec IA — aperçu et validation.
class AiContentScreen extends StatefulWidget {
  const AiContentScreen({super.key});

  @override
  State<AiContentScreen> createState() => _AiContentScreenState();
}

class _AiContentScreenState extends State<AiContentScreen> {
  String _contentType = 'Cours';
  bool _generating = false;
  String? _preview;

  Future<void> _generate() async {
    setState(() => _generating = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _generating = false;
      _preview =
          '# Nombres complexes — Terminale D\n\n'
          '## Objectifs pédagogiques\n'
          '- Comprendre la forme algébrique a + ib\n'
          '- Effectuer les opérations de base\n\n'
          '## Contenu\n'
          'Un nombre complexe z s\'écrit z = a + ib où i² = -1...\n\n'
          '*Généré par IA — À valider avant publication*';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Génération IA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Paramètres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: 'Terminale',
              decoration: const InputDecoration(labelText: 'Niveau'),
              items: ['3e', 'Probatoire', 'Terminale']
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: 'Mathématiques',
              decoration: const InputDecoration(labelText: 'Matière'),
              items: ['Mathématiques', 'Physique', 'Français']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Chapitre MINESEC')),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Objectifs pédagogiques'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _contentType,
              decoration: const InputDecoration(labelText: 'Type de contenu'),
              items: ['Cours', 'Résumé', 'Fiche', 'Exercices', 'Quiz', 'Devoir', 'Épreuve', 'Corrigé']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _contentType = v!),
            ),
            const SizedBox(height: 24),
            LoadingButton(
              label: 'Générer avec l\'IA',
              icon: Icons.auto_awesome,
              isLoading: _generating,
              onPressed: _generate,
            ),
            if (_preview != null) ...[
              const SizedBox(height: 24),
              const SectionHeader(title: 'Aperçu — Modifier avant validation'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_preview!, style: const TextStyle(height: 1.6)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Modifier'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(backgroundColor: AppColors.emeraldGreen),
                      child: const Text('Valider & Publier'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
