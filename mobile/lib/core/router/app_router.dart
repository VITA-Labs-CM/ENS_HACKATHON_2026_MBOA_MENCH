import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../constants/app_constants.dart';
import '../../features/shared/auth/role_selection_screen.dart';
import '../../features/shared/auth/login_screen.dart';
import '../../features/shared/auth/register_screen.dart';
import '../../features/shared/auth/forgot_password_screen.dart';
import '../../features/shared/auth/offline_login_screen.dart';
import '../../features/student/splash/splash_screen.dart';
import '../../features/student/onboarding/onboarding_screen.dart';
import '../../features/student/shell/student_shell.dart';
import '../../features/student/home/student_home_screen.dart';
import '../../features/student/courses/courses_screen.dart';
import '../../features/student/ai/ai_assistant_screen.dart';
import '../../features/student/progress/progress_screen.dart';
import '../../features/student/profile/profile_screen.dart';
import '../../features/student/courses/chapters_screen.dart';
import '../../features/student/courses/course_reader_screen.dart';
import '../../features/student/quiz/quiz_screen.dart';
import '../../features/student/packs/pack_download_screen.dart';
import '../../features/student/packs/ai_model_download_screen.dart';
import '../../features/student/notifications/notifications_screen.dart';
import '../../features/student/settings/settings_screen.dart';
import '../../features/teacher/shell/teacher_shell.dart';
import '../../features/teacher/dashboard/teacher_dashboard_screen.dart';
import '../../features/teacher/classes/classes_screen.dart';
import '../../features/teacher/courses/teacher_courses_screen.dart';
import '../../features/teacher/students/students_screen.dart';
import '../../features/teacher/classes/class_detail_screen.dart';
import '../../features/teacher/offline_classroom/offline_classroom_screen.dart';
import '../../features/teacher/resources/resources_screen.dart';
import '../../features/teacher/books/book_validation_screen.dart';
import '../../features/teacher/ai_generation/ai_content_screen.dart';
import '../../features/teacher/exams/exam_generator_screen.dart';
import '../../features/teacher/videos/video_management_screen.dart';
import '../../features/teacher/analytics/analytics_screen.dart';
import '../../features/teacher/tickets/tickets_screen.dart';
import '../../features/teacher/pack_export/pack_export_screen.dart';
import '../../features/teacher/library/library_screen.dart';
import '../../features/teacher/notifications/teacher_notifications_screen.dart';
import '../../features/teacher/settings/teacher_settings_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Configuration GoRouter — routes élève et enseignant.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == '/splash') return null;
      if (!session.onboardingCompleted && !loc.startsWith('/onboarding') && !loc.startsWith('/auth')) {
        return '/onboarding';
      }
      if (!session.isAuthenticated && !loc.startsWith('/auth') && !loc.startsWith('/onboarding') && loc != '/splash') {
        return '/auth/role';
      }
      if (session.isAuthenticated && loc.startsWith('/auth')) {
        return session.role == UserRole.teacher ? '/teacher' : '/student/home';
      }
      if (loc == '/student') return '/student/home';
      if (loc == '/teacher') return '/teacher';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth/role', builder: (_, __) => const RoleSelectionScreen()),
      GoRoute(
        path: '/auth/login/:role',
        builder: (_, state) => LoginScreen(
          role: state.pathParameters['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
        ),
      ),
      GoRoute(
        path: '/auth/register/:role',
        builder: (_, state) => RegisterScreen(
          role: state.pathParameters['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
        ),
      ),
      GoRoute(path: '/auth/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/auth/offline', builder: (_, __) => const OfflineLoginScreen()),

      // Shell Élève — 5 onglets
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) => StudentShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/student/home', builder: (_, __) => const StudentHomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/student/courses', builder: (_, __) => const CoursesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/student/ai', builder: (_, __) => const AiAssistantScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/student/progress', builder: (_, __) => const ProgressScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/student/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),

      // Routes élève hors shell
      GoRoute(
        path: '/student/courses/:subjectId',
        builder: (_, state) => ChaptersScreen(subjectId: state.pathParameters['subjectId']!),
      ),
      GoRoute(
        path: '/student/chapter/:chapterId/read',
        builder: (_, state) => CourseReaderScreen(chapterId: state.pathParameters['chapterId']!),
      ),
      GoRoute(
        path: '/student/chapter/:chapterId/quiz',
        builder: (_, state) => QuizScreen(chapterId: state.pathParameters['chapterId']!),
      ),
      GoRoute(path: '/student/packs', builder: (_, __) => const PackDownloadScreen()),
      GoRoute(path: '/student/ai-models', builder: (_, __) => const AiModelDownloadScreen()),
      GoRoute(path: '/student/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/student/settings', builder: (_, __) => const SettingsScreen()),

      // Shell Enseignant — 4 onglets principaux
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) => TeacherShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/teacher', builder: (_, __) => const TeacherDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/teacher/classes', builder: (_, __) => const ClassesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/teacher/courses-list', builder: (_, __) => const TeacherCoursesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/teacher/students-tab', builder: (_, __) => const StudentsScreen()),
          ]),
        ],
      ),

      // Routes enseignant hors shell
      GoRoute(
        path: '/teacher/class/:classId',
        builder: (_, state) => ClassDetailScreen(classId: state.pathParameters['classId']!),
      ),
      GoRoute(path: '/teacher/offline-classroom', builder: (_, __) => const OfflineClassroomScreen()),
      GoRoute(path: '/teacher/students', builder: (_, __) => const StudentsScreen()),
      GoRoute(path: '/teacher/resources', builder: (_, __) => const ResourcesScreen()),
      GoRoute(path: '/teacher/books', builder: (_, __) => const BookValidationScreen()),
      GoRoute(path: '/teacher/ai-content', builder: (_, __) => const AiContentScreen()),
      GoRoute(path: '/teacher/exams', builder: (_, __) => const ExamGeneratorScreen()),
      GoRoute(path: '/teacher/videos', builder: (_, __) => const VideoManagementScreen()),
      GoRoute(path: '/teacher/analytics', builder: (_, __) => const AnalyticsScreen()),
      GoRoute(path: '/teacher/tickets', builder: (_, __) => const TicketsScreen()),
      GoRoute(path: '/teacher/pack-export', builder: (_, __) => const PackExportScreen()),
      GoRoute(path: '/teacher/library', builder: (_, __) => const LibraryScreen()),
      GoRoute(path: '/teacher/notifications', builder: (_, __) => const TeacherNotificationsScreen()),
      GoRoute(path: '/teacher/settings', builder: (_, __) => const TeacherSettingsScreen()),
    ],
  );
});
