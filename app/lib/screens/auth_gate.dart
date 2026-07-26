import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../models/user_model.dart';
import 'auth/login_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'vendor/vendor_dashboard_screen.dart';
import 'common/home_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Not logged in - show login screen
          return const LoginScreen();
        }

        // User is logged in - show role-based dashboard
        return currentUser.when(
          data: (appUser) {
            if (appUser == null) {
              return const Scaffold(
                body: Center(
                  child: Text('User data not found'),
                ),
              );
            }

            switch (appUser.role) {
              case UserRole.admin:
                return const AdminDashboardScreen();
              case UserRole.vendor:
                return const VendorDashboardScreen();
              default:
                return const HomeScreen();
            }
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Scaffold(
            body: Center(
              child: Text('Error loading user: $error'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Authentication error: $error'),
        ),
      ),
    );
  }
}