import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Connexion hors ligne — session locale persistante (MVP README).
class OfflineLoginScreen extends ConsumerStatefulWidget {
  const OfflineLoginScreen({super.key});

  @override
  ConsumerState<OfflineLoginScreen> createState() => _OfflineLoginScreenState();
}

class _OfflineLoginScreenState extends ConsumerState<OfflineLoginScreen> {
  bool _loading = false;

  Future<void> _continueOffline() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    await ref.read(sessionProvider.notifier).login(
          name: 'Amina Ndjock',
          role: UserRole.student,
          offline: true,
        );
    if (mounted) context.go('/student/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mode hors ligne')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: AppColors.accentOrange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aucune connexion détectée. Vous pouvez continuer avec votre session locale enregistrée.',
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Icon(Icons.offline_bolt, size: 80, color: AppColors.emeraldGreen),
            const SizedBox(height: 16),
            Text(
              'Session locale disponible',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dernière connexion : Amina Ndjock\nTerminale D — Lycée de Maroua',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.darkGray),
            ),
            const Spacer(),
            LoadingButton(
              label: 'Continuer hors ligne',
              icon: Icons.arrow_forward,
              isLoading: _loading,
              onPressed: _continueOffline,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Retour à la connexion'),
            ),
          ],
        ),
      ),
    );
  }
}
