enum UserRole {
  student,
  professor,
  admin,
}

class UserProfile {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final UserRole role;
  final String? batch;
  final int? semester;
  final String? course;
  final int? admittedYear;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    required this.role,
    this.batch,
    this.semester,
    this.course,
    this.admittedYear,
    this.createdAt,
  });

  // Computed properties
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return 'Unknown User';
  }

  String get email {
    // We'll need to get this from auth user since it's not in profiles table
    return ''; // Will be set from auth context
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: _parseRole(json['role'] as String?),
      batch: json['batch'] as String?,
      semester: json['semester'] as int?,
      course: json['course'] as String?,
      admittedYear: json['admitted_year'] as int?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }  static UserRole _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'professor':
      case 'faculty':
        return UserRole.professor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student; // Default fallback
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'role': role.name,
      'batch': batch,
      'semester': semester,
      'course': course,
      'admitted_year': admittedYear,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Helper methods
  bool get isStudent => role == UserRole.student;
  bool get isProfessor => role == UserRole.professor;
  bool get isAdmin => role == UserRole.admin;

  // Check if user has specific permissions
  bool canCreatePosts() {
    return role == UserRole.professor || role == UserRole.admin;
  }

  bool canViewAllTimetables() {
    return role == UserRole.professor || role == UserRole.admin;
  }

  bool canManageUsers() {
    return role == UserRole.admin;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $fullName, role: ${role.name})';
  }
}
