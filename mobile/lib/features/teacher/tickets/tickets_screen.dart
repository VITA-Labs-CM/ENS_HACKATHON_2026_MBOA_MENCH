import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Gestion des tickets support.
class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  Color _priorityColor(TicketPriority p) => switch (p) {
        TicketPriority.low => AppColors.mediumGray,
        TicketPriority.medium => AppColors.electricBlue,
        TicketPriority.high => AppColors.accentOrange,
        TicketPriority.urgent => AppColors.errorRed,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets support'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.supportTickets.length,
        itemBuilder: (context, index) {
          final t = MockData.supportTickets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${t.category} • ${t.messages} messages'),
              trailing: StatusChip(
                label: t.priority.name,
                color: _priorityColor(t.priority),
              ),
              onTap: () => _showTicketDetail(context, t),
            ),
          );
        },
      ),
    );
  }

  void _showTicketDetail(BuildContext context, SupportTicket t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              Text(t.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Historique des messages...'),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(hintText: 'Répondre...'), maxLines: 3),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Envoyer')),
            ],
          ),
        ),
      ),
    );
  }
}
