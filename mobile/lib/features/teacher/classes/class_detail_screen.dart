import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';

/// Détail d'une classe — code, QR, actions.
class ClassDetailScreen extends StatelessWidget {
  const ClassDetailScreen({super.key, required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context) {
    final cls = MockData.teacherClasses.firstWhere((c) => c.id == classId);

    return Scaffold(
      appBar: AppBar(title: Text(cls.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.electricBlue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.qr_code_2, size: 80, color: AppColors.electricBlue),
                    ),
                    const SizedBox(height: 16),
                    const Text('Code d\'invitation', style: TextStyle(color: AppColors.darkGray)),
                    const SizedBox(height: 8),
                    SelectableText(
                      cls.inviteCode,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: cls.inviteCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copié !')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copier'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                          label: const Text('Partager'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier la classe'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archiver'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.errorRed),
              title: const Text('Supprimer', style: TextStyle(color: AppColors.errorRed)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
