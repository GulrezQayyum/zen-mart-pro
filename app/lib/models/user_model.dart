// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, vendor, user, rider }

extension UserRoleExtension on UserRole {
  String get value => name;
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'vendor':
        return UserRole.vendor;
      case 'rider':
        return UserRole.rider;
      default:
        return UserRole.user;
    }
  }
}

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? phone;
  final String? shopId;
  final String? riderId;
  final String? photoURL;
  final String? status;
  final UserRole role;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.phone,
    this.shopId,
    this.riderId,
    this.photoURL,
    this.status,
    this.role = UserRole.user,
    this.createdAt,
  });

  // ✅ Corrected fromFirestore
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime? createdAt;
    final createdAtField = data['createdAt'];
    if (createdAtField is Timestamp) {
      createdAt = createdAtField.toDate();
    } else if (createdAtField is String) {
      try {
        createdAt = DateTime.parse(createdAtField);
      } catch (_) {
        createdAt = null;
      }
    }

    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phone: data['phone'],
      shopId: data['shopId'],
      riderId: data['riderId'],
      photoURL: data['photoURL'],
      status: data['status'] ?? 'active',
      role: UserRoleExtension.fromString(data['role'] ?? 'user'),
      createdAt: createdAt,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['uid'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      status: json['status'] ?? 'active',
      shopId: json['shopId'],
      role: UserRoleExtension.fromString(json['role'] ?? 'user'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'displayName': displayName,
    'phone': phone,
    'shopId': shopId,
    'riderId': riderId,
    'photoURL': photoURL,
    'status': status ?? 'active',
    'role': role.value,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

// SignUpRequest (keep if used)
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

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'displayName': displayName,
    'role': role.value,
  };
}

// DashboardStats (keep if used)
class DashboardStats {
  final int totalUsers;
  final int totalVendors;
  final bool activeSession;

  DashboardStats({required this.totalUsers, required this.totalVendors, required this.activeSession});

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
    totalUsers: json['totalUsers'] ?? 0,
    totalVendors: json['totalVendors'] ?? 0,
    activeSession: json['activeSession'] ?? true,
  );
}