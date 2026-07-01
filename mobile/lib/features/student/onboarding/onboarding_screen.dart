import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Onboarding en 4 pages — présentation des fonctionnalités clés.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.wifi_off_rounded,
      color: AppColors.electricBlue,
      title: 'Étudier partout',
      description:
          'Même sans Internet. Téléchargez vos cours une fois et apprenez où que vous soyez au Cameroun.',
    ),
    _OnboardingPage(
      icon: Icons.psychology_rounded,
      color: AppColors.emeraldGreen,
      title: 'Votre professeur intelligent',
      description:
          'Un assistant IA qui répond à partir de vos cours, sans hallucination, entièrement hors ligne.',
    ),
    _OnboardingPage(
      icon: Icons.verified_rounded,
      color: AppColors.accentOrange,
      title: 'Contenus validés',
      description:
          'Des supports vérifiés par vos enseignants, alignés sur le programme MINESEC et le format APC.',
    ),
    _OnboardingPage(
      icon: Icons.trending_up_rounded,
      color: AppColors.electricBlue,
      title: 'Progression personnalisée',
      description:
          'Suivez votre avancement, débloquez les chapitres et préparez vos examens BEPC, Probatoire et BAC.',
    ),
  ];

  Future<void> _finish() async {
    await ref.read(sessionProvider.notifier).completeOnboarding();
    if (mounted) context.go('/auth/role');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Passer'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: p.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(p.icon, size: 72, color: p.color),
                        ).animate().scale(duration: 400.ms),
                        const SizedBox(height: 40),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.darkGray,
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: WormEffect(
                dotColor: AppColors.mediumGray.withValues(alpha: 0.4),
                activeDotColor: AppColors.electricBlue,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LoadingButton(
                label: _page == _pages.length - 1 ? 'Commencer' : 'Suivant',
                icon: _page == _pages.length - 1 ? Icons.rocket_launch : Icons.arrow_forward,
                onPressed: () {
                  if (_page < _pages.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _finish();
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
}
