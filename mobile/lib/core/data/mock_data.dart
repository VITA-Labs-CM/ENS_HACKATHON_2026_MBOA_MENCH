import '../constants/app_constants.dart';
import '../models/models.dart';

/// Données simulées pour le développement UI — remplacées par Drift/API plus tard.
abstract final class MockData {
  static const student = StudentProfile(
    id: 'stu-001',
    name: 'Amina Ndjock',
    school: 'Lycée Bilingue de Maroua',
    className: 'Terminale D',
    level: 'Terminale',
    avatarInitials: 'AN',
    xp: 2450,
    levelNumber: 7,
    studyMinutesToday: 47,
    overallProgress: 0.62,
    storageUsedMb: 1240,
    storageTotalMb: 8192,
  );

  static const subjects = [
    Subject(
      id: 'math',
      name: 'Mathématiques',
      icon: 'functions',
      color: 0xFF0066FF,
      chapterCount: 12,
      progress: 0.75,
      completedChapters: 9,
    ),
    Subject(
      id: 'phys',
      name: 'Physique',
      icon: 'science',
      color: 0xFF00C896,
      chapterCount: 10,
      progress: 0.45,
      completedChapters: 4,
    ),
    Subject(
      id: 'fr',
      name: 'Français',
      icon: 'menu_book',
      color: 0xFFFF8C42,
      chapterCount: 8,
      progress: 0.88,
      completedChapters: 7,
    ),
    Subject(
      id: 'hist',
      name: 'Histoire-Géo',
      icon: 'public',
      color: 0xFF8B5CF6,
      chapterCount: 9,
      progress: 0.33,
      completedChapters: 3,
    ),
    Subject(
      id: 'svt',
      name: 'SVT',
      icon: 'eco',
      color: 0xFF10B981,
      chapterCount: 11,
      progress: 0.55,
      completedChapters: 6,
    ),
    Subject(
      id: 'ang',
      name: 'Anglais',
      icon: 'translate',
      color: 0xFFEF4444,
      chapterCount: 7,
      progress: 0.20,
      completedChapters: 1,
    ),
  ];

  static List<Chapter> chaptersFor(String subjectId) {
    final titles = switch (subjectId) {
      'math' => [
        'Nombres complexes',
        'Suites numériques',
        'Fonctions exponentielles',
        'Probabilités',
        'Statistiques',
      ],
      'phys' => [
        'Mécanique du point',
        'Électrocinétique',
        'Ondes mécaniques',
        'Optique géométrique',
      ],
      _ => [
        'Introduction',
        'Concepts fondamentaux',
        'Approfondissement',
        'Révision APC',
        'Évaluation',
      ],
    };

    return List.generate(titles.length, (i) {
      final completed = i < 2;
      final locked = i > 0 && i > 2;
      return Chapter(
        id: '$subjectId-ch-$i',
        subjectId: subjectId,
        title: titles[i],
        order: i + 1,
        estimatedMinutes: 25 + i * 5,
        progress: completed ? 1.0 : (i == 2 ? 0.6 : 0),
        isLocked: locked,
        isCompleted: completed,
        lastScore: completed ? 85 + i * 2 : (i == 2 ? 72 : null),
      );
    });
  }

  static CourseContent courseContent(String chapterId) {
    return CourseContent(
      chapterId: chapterId,
      title: 'Nombres complexes — Forme algébrique',
      sections: const [
        CourseSection(
          title: 'Introduction',
          body:
              'Les nombres complexes étendent l\'ensemble des nombres réels. '
              'Ils sont essentiels pour résoudre certaines équations du second degré '
              'et modéliser des phénomènes oscillatoires en physique.',
        ),
        CourseSection(
          title: 'Définition',
          body:
              'Un nombre complexe z s\'écrit sous la forme z = a + ib, où a et b '
              'sont des nombres réels et i est l\'unité imaginaire telle que i² = -1.\n\n'
              '• a est la partie réelle de z, notée Re(z)\n'
              '• b est la partie imaginaire de z, notée Im(z)',
        ),
        CourseSection(
          title: 'Opérations de base',
          body:
              'Addition : (a + ib) + (c + id) = (a + c) + i(b + d)\n\n'
              'Multiplication : (a + ib)(c + id) = (ac - bd) + i(ad + bc)\n\n'
              'Conjugué : si z = a + ib, alors z̄ = a - ib',
        ),
        CourseSection(
          title: 'Application — Examen BEPC/BAC',
          body:
              'Exercice type : Mettre sous forme algébrique le nombre '
              'z = (2 + 3i)(1 - i).\n\n'
              'Méthode APC : identifier la compétence, appliquer la règle, '
              'vérifier le résultat.',
        ),
      ],
    );
  }

  static const quizQuestions = [
    QuizQuestion(
      id: 'q1',
      type: QuizQuestionType.multipleChoice,
      question: 'Quelle est la partie imaginaire de z = 3 + 5i ?',
      options: ['3', '5', '5i', '3 + 5i'],
      correctAnswer: '5',
      explanation: 'Dans a + ib, la partie imaginaire est b = 5.',
    ),
    QuizQuestion(
      id: 'q2',
      type: QuizQuestionType.trueFalse,
      question: 'i² = -1',
      options: ['Vrai', 'Faux'],
      correctAnswer: 'Vrai',
      explanation: 'Par définition de l\'unité imaginaire.',
    ),
    QuizQuestion(
      id: 'q3',
      type: QuizQuestionType.shortAnswer,
      question: 'Calculez (1 + i)² et donnez la partie réelle.',
      options: [],
      correctAnswer: '0',
      explanation: '(1 + i)² = 1 + 2i + i² = 1 + 2i - 1 = 2i. Partie réelle = 0.',
    ),
    QuizQuestion(
      id: 'q4',
      type: QuizQuestionType.multipleChoice,
      question: 'Le conjugué de 4 - 3i est :',
      options: ['4 + 3i', '-4 + 3i', '4 - 3i', '-4 - 3i'],
      correctAnswer: '4 + 3i',
    ),
    QuizQuestion(
      id: 'q5',
      type: QuizQuestionType.multipleChoice,
      question: 'L\'ensemble des nombres complexes est noté :',
      options: ['ℝ', 'ℕ', 'ℂ', 'ℚ'],
      correctAnswer: 'ℂ',
    ),
  ];

  static final chatHistory = [
    ChatMessage(
      id: 'm1',
      content: 'Bonjour ! Je suis ton assistant MBOA MENCH. Pose-moi une question sur tes cours.',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ChatMessage(
      id: 'm2',
      content: 'Explique-moi les nombres complexes simplement.',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
    ),
    ChatMessage(
      id: 'm3',
      content:
          'Les nombres complexes permettent de résoudre des équations comme x² + 1 = 0. '
          'On les écrit a + ib, où i² = -1. C\'est comme ajouter une dimension aux nombres réels !',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 54)),
    ),
  ];

  static const badges = [
    Badge(id: 'b1', name: 'Premier pas', description: 'Terminer un chapitre', icon: '🎯', isUnlocked: true),
    Badge(id: 'b2', name: 'Quiz parfait', description: '100 % à un quiz', icon: '⭐', isUnlocked: true),
    Badge(id: 'b3', name: 'Régularité', description: '7 jours consécutifs', icon: '🔥', isUnlocked: false),
    Badge(id: 'b4', name: 'Expert Maths', description: 'Terminer tous les chapitres Maths', icon: '🏆', isUnlocked: false),
  ];

  static final eduPacks = [
    EduPack(
      id: 'pack-1',
      name: 'Pack Maths Terminale D',
      subject: 'Mathématiques',
      level: 'Terminale',
      sizeMb: 245,
      stage: PackDownloadStage.completed,
      progress: 1.0,
    ),
    EduPack(
      id: 'pack-2',
      name: 'Pack Physique Proba',
      subject: 'Physique',
      level: 'Probatoire',
      sizeMb: 180,
      stage: PackDownloadStage.downloading,
      progress: 0.45,
      downloadSpeedKbps: 128,
    ),
    EduPack(
      id: 'pack-3',
      name: 'Pack Français 3e BEPC',
      subject: 'Français',
      level: '3e',
      sizeMb: 95,
      stage: PackDownloadStage.idle,
      progress: 0,
    ),
  ];

  static final aiModels = [
    AiModel(
      id: 'emb-1',
      name: 'Embeddings APC (quantifié)',
      sizeMb: 45,
      ramRequiredMb: 256,
      stage: ModelDownloadStage.completed,
      progress: 1.0,
      isInstalled: true,
    ),
    AiModel(
      id: 'llm-1',
      name: 'Phi-3 Mini (4K context)',
      sizeMb: 2100,
      ramRequiredMb: 2048,
      stage: ModelDownloadStage.downloading,
      progress: 0.32,
      downloadSpeedKbps: 95,
    ),
    AiModel(
      id: 'llm-2',
      name: 'Gemma 2B (quantifié)',
      sizeMb: 1500,
      ramRequiredMb: 1536,
      stage: ModelDownloadStage.idle,
      progress: 0,
    ),
  ];

  static final notifications = [
    AppNotification(
      id: 'n1',
      title: 'Nouveau module disponible',
      body: 'Le chapitre « Probabilités » est prêt à télécharger.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      type: 'module',
    ),
    AppNotification(
      id: 'n2',
      title: 'Quiz réussi',
      body: 'Bravo ! Tu as obtenu 85 % au quiz Maths.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      type: 'quiz',
    ),
    AppNotification(
      id: 'n3',
      title: 'Pack Physique indexé',
      body: 'L\'assistant IA peut maintenant répondre sur Physique.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: 'pack',
    ),
  ];

  // --- Données enseignant ---

  static const teacherName = 'Prof. Jean-Baptiste Mballa';

  static const teacherClasses = [
    TeacherClass(
      id: 'cls-1',
      name: 'Terminale D — Maths',
      level: 'Terminale',
      school: 'Lycée Bilingue de Maroua',
      subject: 'Mathématiques',
      schoolYear: '2025-2026',
      inviteCode: 'MBOA-TD24',
      studentCount: 42,
      status: ClassStatus.open,
    ),
    TeacherClass(
      id: 'cls-2',
      name: 'Probatoire C — Physique',
      level: 'Probatoire',
      school: 'Collège Saint-Joseph Garoua',
      subject: 'Physique',
      schoolYear: '2025-2026',
      inviteCode: 'MBOA-PC18',
      studentCount: 38,
      status: ClassStatus.open,
    ),
    TeacherClass(
      id: 'cls-3',
      name: '3e — Français BEPC',
      level: '3e',
      school: 'École Publique de Mokolo',
      subject: 'Français',
      schoolYear: '2025-2026',
      inviteCode: 'MBOA-3F09',
      studentCount: 55,
      status: ClassStatus.closed,
    ),
  ];

  static final classStudents = [
    ClassStudent(
      id: 's1',
      name: 'Amina Ndjock',
      progress: 0.78,
      status: StudentStatus.onTrack,
      lastActivity: DateTime.now().subtract(const Duration(hours: 3)),
      quizAverage: 82,
      modulesCompleted: 7,
      badges: 3,
    ),
    ClassStudent(
      id: 's2',
      name: 'Ibrahim Abba',
      progress: 0.45,
      status: StudentStatus.behind,
      lastActivity: DateTime.now().subtract(const Duration(days: 4)),
      quizAverage: 58,
      modulesCompleted: 3,
      badges: 1,
    ),
    ClassStudent(
      id: 's3',
      name: 'Fatou Diallo',
      progress: 0.32,
      status: StudentStatus.struggling,
      lastActivity: DateTime.now().subtract(const Duration(days: 7)),
      quizAverage: 42,
      modulesCompleted: 2,
      badges: 0,
    ),
    ClassStudent(
      id: 's4',
      name: 'Samuel Ewodo',
      progress: 0.91,
      status: StudentStatus.onTrack,
      lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
      quizAverage: 94,
      modulesCompleted: 9,
      badges: 5,
    ),
  ];

  static const teacherCourses = [
    TeacherCourse(
      id: 'crs-1',
      title: 'Nombres complexes — Forme algébrique',
      description: 'Introduction aux nombres complexes pour Terminale D.',
      subject: 'Mathématiques',
      level: 'Terminale',
      chapter: 'Chapitre 3',
      durationMinutes: 45,
      isPublished: true,
      competencies: ['Calculer avec les complexes', 'Résoudre des équations du 2nd degré'],
    ),
    TeacherCourse(
      id: 'crs-2',
      title: 'Suites numériques',
      description: 'Suites arithmétiques et géométriques',
      subject: 'Mathématiques',
      level: 'Terminale',
      chapter: 'Chapitre 4',
      durationMinutes: 50,
      isPublished: false,
      competencies: ['Identifier une suite', 'Calculer un terme général'],
    ),
  ];

  static const resources = [
    Resource(
      id: 'res-1',
      name: 'Cours_Nombres_Complexes.pdf',
      type: 'PDF',
      sizeMb: 2.4,
      pageCount: 12,
      isValidated: true,
      analysisStatus: 'Analysé',
    ),
    Resource(
      id: 'res-2',
      name: 'Exercices_Suites.docx',
      type: 'DOCX',
      sizeMb: 0.8,
      pageCount: 5,
      isValidated: false,
      analysisStatus: 'En attente',
    ),
  ];

  static const proposedBooks = [
    ProposedBook(
      id: 'bk-1',
      title: 'Mathématiques Terminale D — Collection MINESEC',
      author: 'Collectif MINESEC',
      subject: 'Mathématiques',
      level: 'Terminale',
      program: 'Programme officiel 2024-2025',
      summary: 'Manuel aligné sur le programme APC pour la Terminale D.',
      source: 'Bibliothèque MINESEC',
      confidenceScore: 0.96,
      programMatch: 0.98,
    ),
  ];

  static final supportTickets = [
    SupportTicket(
      id: 'tkt-1',
      title: 'Problème d\'export de pack',
      category: 'Technique',
      priority: TicketPriority.high,
      status: TicketStatus.open,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      messages: 2,
    ),
  ];

  static final recentActivities = [
    RecentActivity(
      id: 'a1',
      title: 'Amina a terminé un quiz',
      subtitle: 'Mathématiques — 85 %',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: 'quiz',
    ),
    RecentActivity(
      id: 'a2',
      title: 'Nouveau cours publié',
      subtitle: 'Suites numériques',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      icon: 'book',
    ),
  ];

  /// Données XP pour le graphique de progression (7 derniers jours).
  static const weeklyXp = [120, 180, 90, 210, 150, 240, 190];

  /// Compétences APC simulées.
  static const skills = [
    ('Calcul algébrique', 0.85),
    ('Raisonnement', 0.72),
    ('Modélisation', 0.58),
    ('Communication', 0.90),
  ];
}