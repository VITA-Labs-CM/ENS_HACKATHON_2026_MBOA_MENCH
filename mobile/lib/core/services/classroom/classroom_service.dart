import 'dart:async';
import 'package:uuid/uuid.dart';

/// Service for classroom entity management — CRUD + join via code.
///
/// Supports both online and offline operations:
/// - Classrooms are persisted locally for offline access
/// - Sync happens when connectivity is available
class ClassroomService {
  ClassroomService();

  final _uuid = const Uuid();

  /// In-memory store — will be backed by SQLite via SyncService.
  final Map<String, Classroom> _classrooms = {};
  final Map<String, List<String>> _studentEnrollments = {}; // classId → [studentIds]

  /// Stream of classroom updates.
  final _classroomController = StreamController<List<Classroom>>.broadcast();
  Stream<List<Classroom>> get classroomStream => _classroomController.stream;

  /// Create a new classroom (teacher action).
  Future<Classroom> createClassroom({
    required String name,
    required String subject,
    required String level,
    required String school,
    required String teacherId,
    required String schoolYear,
  }) async {
    final id = _uuid.v4();
    final inviteCode = _generateInviteCode();

    final classroom = Classroom(
      id: id,
      name: name,
      subject: subject,
      level: level,
      school: school,
      teacherId: teacherId,
      schoolYear: schoolYear,
      inviteCode: inviteCode,
      mode: ClassroomMode.cloud, // default to cloud
      status: ClassroomConnectionStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      studentCount: 0,
    );

    _classrooms[id] = classroom;
    _studentEnrollments[id] = [];
    _notifyChange();

    return classroom;
  }

  /// Join a classroom via invite code (student action).
  Future<JoinResult> joinClassroom({
    required String inviteCode,
    required String studentId,
    required String studentName,
  }) async {
    // Find classroom by code
    final classroom = _classrooms.values.firstWhere(
      (c) =>
          c.inviteCode.toUpperCase() == inviteCode.toUpperCase() &&
          c.status == ClassroomConnectionStatus.active,
      orElse: () => throw ClassroomNotFoundException(inviteCode),
    );

    // Check if already enrolled
    final enrolled = _studentEnrollments[classroom.id] ?? [];
    if (enrolled.contains(studentId)) {
      return JoinResult(
        success: true,
        classroom: classroom,
        message: 'Déjà inscrit dans cette classe',
        alreadyEnrolled: true,
      );
    }

    // Enroll
    enrolled.add(studentId);
    _studentEnrollments[classroom.id] = enrolled;

    // Update student count
    _classrooms[classroom.id] = classroom.copyWith(
      studentCount: enrolled.length,
      updatedAt: DateTime.now(),
    );
    _notifyChange();

    return JoinResult(
      success: true,
      classroom: _classrooms[classroom.id]!,
      message: 'Inscrit avec succès dans ${classroom.name}',
      alreadyEnrolled: false,
    );
  }

  /// Get all classrooms for a teacher.
  List<Classroom> getTeacherClassrooms(String teacherId) {
    return _classrooms.values
        .where((c) => c.teacherId == teacherId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Get all classrooms a student is enrolled in.
  List<Classroom> getStudentClassrooms(String studentId) {
    final classIds = <String>[];
    _studentEnrollments.forEach((classId, students) {
      if (students.contains(studentId)) classIds.add(classId);
    });
    return classIds
        .map((id) => _classrooms[id])
        .whereType<Classroom>()
        .toList();
  }

  /// Get a specific classroom.
  Classroom? getClassroom(String classId) => _classrooms[classId];

  /// Set classroom mode (LAN or Cloud).
  void setMode(String classId, ClassroomMode mode) {
    final classroom = _classrooms[classId];
    if (classroom == null) return;
    _classrooms[classId] = classroom.copyWith(
      mode: mode,
      updatedAt: DateTime.now(),
    );
    _notifyChange();
  }

  /// Archive a classroom (teacher action).
  void archiveClassroom(String classId) {
    final classroom = _classrooms[classId];
    if (classroom == null) return;
    _classrooms[classId] = classroom.copyWith(
      status: ClassroomConnectionStatus.archived,
      updatedAt: DateTime.now(),
    );
    _notifyChange();
  }

  /// Generate a 8-char alphanumeric invite code.
  String _generateInviteCode() {
    final code = 'MBOA-${_uuid.v4().substring(0, 4).toUpperCase()}';
    return code;
  }

  void _notifyChange() {
    if (!_classroomController.isClosed) {
      _classroomController.add(_classrooms.values.toList());
    }
  }

  void dispose() {
    _classroomController.close();
  }
}

/// Classroom entity with full metadata.
class Classroom {
  const Classroom({
    required this.id,
    required this.name,
    required this.subject,
    required this.level,
    required this.school,
    required this.teacherId,
    required this.schoolYear,
    required this.inviteCode,
    required this.mode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.studentCount,
    this.lanServerAddress,
  });

  final String id;
  final String name;
  final String subject;
  final String level;
  final String school;
  final String teacherId;
  final String schoolYear;
  final String inviteCode;
  final ClassroomMode mode;
  final ClassroomConnectionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int studentCount;
  final String? lanServerAddress;

  Classroom copyWith({
    String? name,
    ClassroomMode? mode,
    ClassroomConnectionStatus? status,
    DateTime? updatedAt,
    int? studentCount,
    String? lanServerAddress,
  }) {
    return Classroom(
      id: id,
      name: name ?? this.name,
      subject: subject,
      level: level,
      school: school,
      teacherId: teacherId,
      schoolYear: schoolYear,
      inviteCode: inviteCode,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentCount: studentCount ?? this.studentCount,
      lanServerAddress: lanServerAddress ?? this.lanServerAddress,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subject': subject,
        'level': level,
        'school': school,
        'teacher_id': teacherId,
        'school_year': schoolYear,
        'invite_code': inviteCode,
        'mode': mode.name,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'student_count': studentCount,
      };

  factory Classroom.fromJson(Map<String, dynamic> json) => Classroom(
        id: json['id'] as String,
        name: json['name'] as String,
        subject: json['subject'] as String,
        level: json['level'] as String,
        school: json['school'] as String,
        teacherId: json['teacher_id'] as String,
        schoolYear: json['school_year'] as String,
        inviteCode: json['invite_code'] as String,
        mode: ClassroomMode.values.byName(json['mode'] as String),
        status: ClassroomConnectionStatus.values
            .byName(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        studentCount: json['student_count'] as int,
      );
}

/// Result of a join operation.
class JoinResult {
  const JoinResult({
    required this.success,
    required this.classroom,
    required this.message,
    required this.alreadyEnrolled,
  });

  final bool success;
  final Classroom classroom;
  final String message;
  final bool alreadyEnrolled;
}

/// Classroom connectivity mode.
enum ClassroomMode {
  /// Teacher device acts as local server (hotspot/WiFi).
  lan,

  /// Central backend API — remote access.
  cloud,
}

/// Classroom lifecycle status.
enum ClassroomConnectionStatus {
  active,
  archived,
  suspended,
}

/// Exception when classroom invite code not found.
class ClassroomNotFoundException implements Exception {
  const ClassroomNotFoundException(this.inviteCode);
  final String inviteCode;

  @override
  String toString() => 'Aucune classe trouvée avec le code: $inviteCode';
}
