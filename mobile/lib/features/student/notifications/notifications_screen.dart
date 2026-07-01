import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';

/// Centre de notifications élève.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Tout lire')),
        ],
      ),
      body: ListView.builder(
        itemCount: MockData.notifications.length,
        itemBuilder: (context, index) {
          final n = MockData.notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: n.isRead
                  ? AppColors.mediumGray.withValues(alpha: 0.2)
                  : AppColors.electricBlue.withValues(alpha: 0.12),
              child: Icon(
                _iconForType(n.type),
                color: n.isRead ? AppColors.mediumGray : AppColors.electricBlue,
                size: 20,
              ),
            ),
            title: Text(
              n.title,
              style: TextStyle(
                fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.body),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM, HH:mm', 'fr').format(n.timestamp),
                  style: TextStyle(fontSize: 12, color: AppColors.darkGray),
                ),
              ],
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) => switch (type) {
        'module' => Icons.menu_book,
        'quiz' => Icons.quiz,
        'pack' => Icons.download,
        _ => Icons.notifications,
      };
}
