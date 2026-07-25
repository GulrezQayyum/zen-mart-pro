import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user data provider
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUserData();
});

// User role stream provider
final userRoleProvider = StreamProvider.family<UserRole?, String>((ref, uid) {
  final authService = ref.watch(authServiceProvider);
  return authService.getUserRoleStream(uid);
});

// Sign up provider
final signUpProvider = FutureProvider.family<AppUser?, SignUpRequest>((ref, request) async {
  final authService = ref.watch(authServiceProvider);
  final user = await authService.signUp(
    email: request.email,
    password: request.password,
    displayName: request.displayName,
    role: request.role,
  );
  return user;
});

// Sign in provider
final signInProvider = FutureProvider.family<AppUser?, Map<String, String>>((ref, credentials) async {
  final authService = ref.watch(authServiceProvider);
  final user = await authService.signIn(
    email: credentials['email']!,
    password: credentials['password']!,
  );
  return user;
});

// Admin check provider
final isAdminProvider = FutureProvider.family<bool, String>((ref, uid) async {
  final authService = ref.watch(authServiceProvider);
  return authService.isUserAdmin(uid);
});

// Vendor check provider
final isVendorProvider = FutureProvider.family<bool, String>((ref, uid) async {
  final authService = ref.watch(authServiceProvider);
  return authService.isUserVendor(uid);
});

// Sign out notifier
final signOutProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(authServiceProvider);
  await authService.signOut();
});