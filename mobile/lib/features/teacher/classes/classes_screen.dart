import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Gestion des classes — CRUD simulé.
class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Classes'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showCreateDialog(context)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.teacherClasses.length,
        itemBuilder: (context, index) {
          final cls = MockData.teacherClasses[index];
          final statusColor = cls.status == ClassStatus.open
              ? AppColors.emeraldGreen
              : AppColors.mediumGray;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => context.push('/teacher/class/${cls.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(cls.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        StatusChip(
                          label: cls.status == ClassStatus.open ? 'Ouverte' : 'Fermée',
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${cls.school} • ${cls.schoolYear}'),
                    Text('${cls.subject} • ${cls.level}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _InfoChip(Icons.people, '${cls.studentCount} élèves'),
                        const SizedBox(width: 12),
                        _InfoChip(Icons.qr_code, cls.inviteCode),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.qr_code_2),
                            label: const Text('QR Code'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => context.push('/teacher/class/${cls.id}'),
                            child: const Text('Gérer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle classe'),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Créer une classe'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Nom de la classe')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Matière')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Niveau')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Créer')),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.electricBlue),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.darkGray)),
      ],
    );
  }
}
