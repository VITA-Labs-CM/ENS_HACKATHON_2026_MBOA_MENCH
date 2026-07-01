/// Constantes globales de l'application MBOA MENCH.
abstract final class AppConstants {
  static const appName = 'MBOA MENCH';
  static const appSlogan = "L'École dans la poche";
  static const appVersion = '1.0.0';

  /// Score minimum pour débloquer le chapitre suivant (80 %).
  static const chapterUnlockScore = 80;

  /// Seuil de progression pour statut « en difficulté ».
  static const difficultyThreshold = 50;

  /// Durée du splash screen en millisecondes.
  static const splashDurationMs = 2800;

  static const onboardingKey = 'onboarding_completed';
  static const themeModeKey = 'theme_mode';
  static const userRoleKey = 'user_role';
  static const sessionKey = 'user_session';
}

/// Rôles utilisateur supportés par l'application.
enum UserRole { student, teacher }

/// Modes de thème disponibles.
enum AppThemeMode { light, dark, system }

/// Étapes de téléchargement d'un pack pédagogique.
enum PackDownloadStage {
  idle,
  downloading,
  verifying,
  installing,
  indexing,
  completed,
  error,
}

/// Étapes de téléchargement d'un modèle IA.
enum ModelDownloadStage {
  idle,
  downloading,
  verifyingSha256,
  decompressing,
  installing,
  optimizing,
  completed,
  error,
}

/// Types de questions de quiz (format APC).
enum QuizQuestionType { multipleChoice, trueFalse, shortAnswer }

/// Statut d'un élève pour le suivi enseignant.
enum StudentStatus { onTrack, behind, struggling }

/// État d'une classe.
enum ClassStatus { open, closed, archived }

/// Priorité d'un ticket support.
enum TicketPriority { low, medium, high, urgent }

/// Statut d'un ticket support.
enum TicketStatus { open, inProgress, resolved, closed }
