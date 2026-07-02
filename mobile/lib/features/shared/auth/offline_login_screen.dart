import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/account_providers.dart';
import '../../../core/services/auth/account_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Connexion hors ligne — restaure la dernière session SQLite.
class OfflineLoginScreen extends ConsumerStatefulWidget {
  const OfflineLoginScreen({super.key});

  @override
  ConsumerState<OfflineLoginScreen> createState() => _OfflineLoginScreenState();
}

class _OfflineLoginScreenState extends ConsumerState<OfflineLoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _continueOffline() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(sessionProvider.notifier).loginOffline();
      if (mounted) {
        final role = ref.read(sessionProvider).role;
        context.go(role == UserRole.teacher ? '/teacher' : '/student/home');
      }
    } on AccountException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastAccount = ref.watch(lastAccountProvider);

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
            lastAccount.when(
              data: (account) {
                if (account == null) {
                  return const Text(
                    'Aucun compte enregistré sur cet appareil.\nCréez un compte ou connectez-vous en ligne.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.darkGray),
                  );
                }
                final details = [
                  account.name,
                  if (account.className.isNotEmpty) account.className,
                  if (account.school.isNotEmpty) account.school,
                ].join('\n');
                return Text(
                  'Dernière connexion :\n$details',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.darkGray),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text(
                'Impossible de charger la session locale.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.errorRed)),
            ],
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
