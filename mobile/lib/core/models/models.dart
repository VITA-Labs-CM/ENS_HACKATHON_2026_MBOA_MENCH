import '../constants/app_constants.dart';

/// Modèle élève — prêt pour sérialisation Drift/API.
class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.name,
    required this.school,
    required this.className,
    required this.level,
    required this.avatarInitials,
    this.xp = 0,
    this.levelNumber = 1,
    this.studyMinutesToday = 0,
    this.overallProgress = 0,
    this.storageUsedMb = 0,
    this.storageTotalMb = 8192,
  });

  final String id;
  final String name;
  final String school;
  final String className;
  final String level;
  final String avatarInitials;
  final int xp;
  final int levelNumber;
  final int studyMinutesToday;
  final double overallProgress;
  final double storageUsedMb;
  final double storageTotalMb;
}

/// Matière scolaire avec progression.
class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.chapterCount,
    required this.progress,
    required this.completedChapters,
  });

  final String id;
  final String name;
  final String icon;
  final int color;
  final int chapterCount;
  final double progress;
  final int completedChapters;
}

/// Chapitre d'une matière — verrouillage si score < 80 % au chapitre précédent.
class Chapter {
  const Chapter({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.order,
    required this.estimatedMinutes,
    required this.progress,
    required this.isLocked,
    required this.isCompleted,
    this.lastScore,
  });

  final String id;
  final String subjectId;
  final String title;
  final int order;
  final int estimatedMinutes;
  final double progress;
  final bool isLocked;
  final bool isCompleted;
  final int? lastScore;
}

/// Contenu d'un chapitre pour le lecteur.
class CourseContent {
  const CourseContent({
    required this.chapterId,
    required this.title,
    required this.sections,
  });

  final String chapterId;
  final String title;
  final List<CourseSection> sections;
}

class CourseSection {
  const CourseSection({
    required this.title,
    required this.body,
    this.imageUrl,
  });

  final String title;
  final String body;
  final String? imageUrl;
}

/// Question de quiz APC.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  final String id;
  final QuizQuestionType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
}

/// Message du chat IA (UI seulement pour le MVP).
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.attachments = const [],
  });

  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String> attachments;
}

/// Badge de gamification.
class Badge {
  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isUnlocked;
}

/// Pack pédagogique téléchargeable.
class EduPack {
  const EduPack({
    required this.id,
    required this.name,
    required this.subject,
    required this.level,
    required this.sizeMb,
    required this.stage,
    required this.progress,
    this.downloadSpeedKbps,
  });

  final String id;
  final String name;
  final String subject;
  final String level;
  final double sizeMb;
  final PackDownloadStage stage;
  final double progress;
  final double? downloadSpeedKbps;
}

/// Modèle IA embarqué (Phi-3, Gemma, embeddings).
class AiModel {
  const AiModel({
    required this.id,
    required this.name,
    required this.sizeMb,
    required this.ramRequiredMb,
    required this.stage,
    required this.progress,
    this.downloadSpeedKbps,
    this.isInstalled = false,
  });

  final String id;
  final String name;
  final double sizeMb;
  final int ramRequiredMb;
  final ModelDownloadStage stage;
  final double progress;
  final double? downloadSpeedKbps;
  final bool isInstalled;
}

/// Notification in-app.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type;
}

/// Classe enseignant.
class TeacherClass {
  const TeacherClass({
    required this.id,
    required this.name,
    required this.level,
    required this.school,
    required this.subject,
    required this.schoolYear,
    required this.inviteCode,
    required this.studentCount,
    required this.status,
  });

  final String id;
  final String name;
  final String level;
  final String school;
  final String subject;
  final String schoolYear;
  final String inviteCode;
  final int studentCount;
  final ClassStatus status;
}

/// Élève suivi par l'enseignant.
class ClassStudent {
  const ClassStudent({
    required this.id,
    required this.name,
    required this.progress,
    required this.status,
    required this.lastActivity,
    required this.quizAverage,
    required this.modulesCompleted,
    required this.badges,
  });

  final String id;
  final String name;
  final double progress;
  final StudentStatus status;
  final DateTime lastActivity;
  final double quizAverage;
  final int modulesCompleted;
  final int badges;
}

/// Cours enseignant.
class TeacherCourse {
  const TeacherCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.level,
    required this.chapter,
    required this.durationMinutes,
    required this.isPublished,
    required this.competencies,
  });

  final String id;
  final String title;
  final String description;
  final String subject;
  final String level;
  final String chapter;
  final int durationMinutes;
  final bool isPublished;
  final List<String> competencies;
}

/// Ressource pédagogique importée.
class Resource {
  const Resource({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeMb,
    required this.pageCount,
    required this.isValidated,
    required this.analysisStatus,
  });

  final String id;
  final String name;
  final String type;
  final double sizeMb;
  final int pageCount;
  final bool isValidated;
  final String analysisStatus;
}

/// Ouvrage proposé par l'IA pour validation MINESEC.
class ProposedBook {
  const ProposedBook({
    required this.id,
    required this.title,
    required this.author,
    required this.subject,
    required this.level,
    required this.program,
    required this.summary,
    required this.source,
    required this.confidenceScore,
    required this.programMatch,
  });

  final String id;
  final String title;
  final String author;
  final String subject;
  final String level;
  final String program;
  final String summary;
  final String source;
  final double confidenceScore;
  final double programMatch;
}

/// Ticket support enseignant.
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.messages,
  });

  final String id;
  final String title;
  final String category;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;
  final int messages;
}

/// Activité récente pour le dashboard enseignant.
class RecentActivity {
  const RecentActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String icon;
}
