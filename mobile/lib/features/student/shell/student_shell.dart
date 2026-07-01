import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../home/student_home_screen.dart';
import '../courses/courses_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../progress/progress_screen.dart';
import '../profile/profile_screen.dart';

/// Shell élève avec Bottom Navigation (5 onglets).
class StudentShell extends StatelessWidget {
  const StudentShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (icon: Icons.home_rounded, label: 'Accueil'),
    (icon: Icons.menu_book_rounded, label: 'Cours'),
    (icon: Icons.psychology_rounded, label: 'IA'),
    (icon: Icons.insights_rounded, label: 'Progression'),
    (icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: _destinations
            .map((d) => NavigationDestination(icon: Icon(d.icon), label: d.label))
            .toList(),
      ),
      floatingActionButton: navigationShell.currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/student/packs'),
              backgroundColor: AppColors.emeraldGreen,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Packs'),
            )
          : null,
    );
  }
}

/// Branches du shell élève — une par onglet.
class StudentTabScreens {
  static const home = StudentHomeScreen();
  static const courses = CoursesScreen();
  static const ai = AiAssistantScreen();
  static const progress = ProgressScreen();
  static const profile = ProfileScreen();
}
