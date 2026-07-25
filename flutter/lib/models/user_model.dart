enum UserRole { admin, vendor, user }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.vendor:
        return 'vendor';
      case UserRole.user:
        return 'user';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'vendor':
        return UserRole.vendor;
      default:
        return UserRole.user;
    }
  }
}

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? photoURL;
  final DateTime createdAt;
  final String status;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoURL,
    required this.createdAt,
    this.status = 'active',
  });

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    String? photoURL,
    DateTime? createdAt,
    String? status,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.value,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: UserRoleExtension.fromString(json['role'] ?? 'user'),
      photoURL: json['photoURL'],
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      status: json['status'] ?? 'active',
    );
  }
}

class SignUpRequest {
  final String email;
  final String password;
  final String displayName;
  final UserRole role;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.displayName,
    this.role = UserRole.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'displayName': displayName,
      'role': role.value,
    };
  }
}

class DashboardStats {
  final int totalUsers;
  final int totalVendors;
  final bool activeSession;

  DashboardStats({
    required this.totalUsers,
    required this.totalVendors,
    required this.activeSession,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalVendors: json['totalVendors'] ?? 0,
      activeSession: json['activeSession'] ?? true,
    );
  }
}