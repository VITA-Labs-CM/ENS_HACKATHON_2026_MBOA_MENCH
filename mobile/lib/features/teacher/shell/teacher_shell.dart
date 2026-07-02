import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../dashboard/teacher_dashboard_screen.dart';
import '../classes/classes_screen.dart';
import '../courses/teacher_courses_screen.dart';
import '../students/students_screen.dart';

/// Shell enseignant — NavigationRail (desktop) + BottomNav (mobile) + Drawer.
class TeacherShell extends StatelessWidget {
  const TeacherShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard'),
    (icon: Icons.class_rounded, label: 'Classes'),
    (icon: Icons.menu_book_rounded, label: 'Cours'),
    (icon: Icons.people_rounded, label: 'Élèves'),
  ];

  static const _drawerRoutes = [
    ('/teacher/offline-classroom', Icons.wifi_tethering, 'Salle locale'),
    ('/teacher/resources', Icons.folder_open, 'Ressources'),
    ('/teacher/books', Icons.library_books, 'Livres MINESEC'),
    ('/teacher/ai-content', Icons.auto_awesome, 'Génération IA'),
    ('/teacher/exams', Icons.assignment, 'Épreuves'),
    ('/teacher/videos', Icons.videocam, 'Vidéos'),
    ('/teacher/analytics', Icons.analytics, 'Analyse IA'),
    ('/teacher/tickets', Icons.support_agent, 'Tickets'),
    ('/teacher/pack-export', Icons.archive, 'Export Packs'),
    ('/teacher/library', Icons.collections_bookmark, 'Bibliothèque'),
    ('/teacher/notifications', Icons.notifications, 'Notifications'),
    ('/teacher/settings', Icons.settings, 'Paramètres'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;
    final isExtended = width >= 1200;

    return Scaffold(
      drawer: isWide ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              extended: isExtended,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: navigationShell.goBranch,
              labelType: isExtended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: _tabs
                  .map((t) => NavigationRailDestination(
                        icon: Icon(t.icon),
                        label: Text(t.label),
                      ))
                  .toList(),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => _showMoreMenu(context),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: navigationShell.goBranch,
              destinations: _tabs
                  .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMoreMenu(context),
        backgroundColor: AppColors.emeraldGreen,
        child: const Icon(Icons.apps),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'EduLocal AI',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'MBOA MENCH Enseignant',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          ..._drawerRoutes.map((r) => ListTile(
                leading: Icon(r.$2),
                title: Text(r.$3),
                onTap: () {
                  Navigator.pop(context);
                  context.push(r.$1);
                },
              )),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: _drawerRoutes
              .map((r) => ListTile(
                    leading: Icon(r.$2, color: AppColors.electricBlue),
                    title: Text(r.$3),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push(r.$1);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

/// Écrans des onglets principaux enseignant.
class TeacherTabScreens {
  static const dashboard = TeacherDashboardScreen();
  static const classes = ClassesScreen();
  static const courses = TeacherCoursesScreen();
  static const students = StudentsScreen();
}
