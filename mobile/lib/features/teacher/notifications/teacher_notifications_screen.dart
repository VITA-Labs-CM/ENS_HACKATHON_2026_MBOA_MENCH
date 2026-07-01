import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Notifications enseignant.
class TeacherNotificationsScreen extends StatelessWidget {
  const TeacherNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Nouvelle soumission', 'Quiz Physique en attente de validation', Icons.upload_file),
      ('Validation', 'Livre MINESEC approuvé', Icons.check_circle),
      ('Ticket', 'Réponse au ticket #001', Icons.support_agent),
      ('IA', 'Recommandation : module de renforcement', Icons.auto_awesome),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final (title, body, icon) = items[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
              child: Icon(icon, color: AppColors.electricBlue, size: 20),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(body),
          );
        },
      ),
    );
  }
}
