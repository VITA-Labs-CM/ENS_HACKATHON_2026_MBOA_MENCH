import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Génération d'épreuves — quiz, devoirs, examens.
class ExamGeneratorScreen extends StatelessWidget {
  const ExamGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Génération d\'épreuves')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: 'Quiz interactif',
              decoration: const InputDecoration(labelText: 'Type d\'épreuve'),
              items: ['Quiz interactif', 'Devoir', 'Examen', 'Sujet PDF', 'Document Word']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: 'Moyen',
              decoration: const InputDecoration(labelText: 'Difficulté'),
              items: ['Facile', 'Moyen', 'Difficile']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Durée (minutes)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Barème total'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Nombre de questions'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Compétences évaluées (APC)'), maxLines: 2),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Génération automatique par IA'),
              subtitle: const Text('L\'IA propose les questions, vous validez'),
              value: true,
              onChanged: (_) {},
            ),
            const SizedBox(height: 24),
            LoadingButton(label: 'Générer l\'épreuve', icon: Icons.assignment, onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
