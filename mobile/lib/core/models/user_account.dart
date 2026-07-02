import '../constants/app_constants.dart';

/// Compte utilisateur persisté en SQLite (élève ou enseignant).
class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.identifier,
    required this.role,
    this.school = '',
    this.className = '',
    this.level = '',
    this.xp = 0,
    this.levelNumber = 1,
    this.studyMinutesToday = 0,
    this.overallProgress = 0,
    this.storageUsedMb = 0,
    this.storageTotalMb = 8192,
    this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String name;
  final String identifier;
  final UserRole role;
  final String school;
  final String className;
  final String level;
  final int xp;
  final int levelNumber;
  final int studyMinutesToday;
  final double overallProgress;
  final double storageUsedMb;
  final double storageTotalMb;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  String get avatarInitials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  UserAccount copyWith({
    String? name,
    String? school,
    String? className,
    String? level,
    int? xp,
    int? levelNumber,
    int? studyMinutesToday,
    double? overallProgress,
    double? storageUsedMb,
    DateTime? lastLoginAt,
  }) {
    return UserAccount(
      id: id,
      name: name ?? this.name,
      identifier: identifier,
      role: role,
      school: school ?? this.school,
      className: className ?? this.className,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      levelNumber: levelNumber ?? this.levelNumber,
      studyMinutesToday: studyMinutesToday ?? this.studyMinutesToday,
      overallProgress: overallProgress ?? this.overallProgress,
      storageUsedMb: storageUsedMb ?? this.storageUsedMb,
      storageTotalMb: storageTotalMb,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  factory UserAccount.fromMap(Map<String, Object?> map) {
    return UserAccount(
      id: map['id'] as String,
      name: map['name'] as String,
      identifier: map['identifier'] as String,
      role: UserRole.values.byName(map['role'] as String),
      school: map['school'] as String? ?? '',
      className: map['class_name'] as String? ?? '',
      level: map['level'] as String? ?? '',
      xp: map['xp'] as int? ?? 0,
      levelNumber: map['level_number'] as int? ?? 1,
      studyMinutesToday: map['study_minutes_today'] as int? ?? 0,
      overallProgress: (map['overall_progress'] as num?)?.toDouble() ?? 0,
      storageUsedMb: (map['storage_used_mb'] as num?)?.toDouble() ?? 0,
      storageTotalMb: (map['storage_total_mb'] as num?)?.toDouble() ?? 8192,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'] as String)
          : null,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'identifier': identifier,
      'role': role.name,
      'school': school,
      'class_name': className,
      'level': level,
      'xp': xp,
      'level_number': levelNumber,
      'study_minutes_today': studyMinutesToday,
      'overall_progress': overallProgress,
      'storage_used_mb': storageUsedMb,
      'storage_total_mb': storageTotalMb,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      if (lastLoginAt != null) 'last_login_at': lastLoginAt!.toIso8601String(),
    };
  }
}
