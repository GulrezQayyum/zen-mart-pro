// lib/screens/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../models/user_model.dart';
import './auth/login_screen.dart';

// Import your dashboards
import './admin/admin_dashboard_screen.dart';   // AdminDashboardScreen
import './vendor/vendor_dashboard_screen.dart'; // VendorDashboardScreen
import './customer/customer_home.dart';         // CustomerHome
import './rider/rider_dashboard.dart';          // RiderDashboard

class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          return const LoginScreen();
        }

        final userDataAsync = ref.watch(currentUserProvider);

        return userDataAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading user data: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(currentUserProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (appUser) {
            if (appUser == null) {
              return const LoginScreen();
            }
            // 🎯 Directly return the dashboard based on role
            return _buildDashboard(appUser);
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Auth error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(authStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(AppUser appUser) {
    switch (appUser.role) {
      case UserRole.admin:
        return AdminDashboardScreen();
      case UserRole.vendor:
        return VendorDashboardScreen();
      case UserRole.user:
        return CustomerHome();
      case UserRole.rider:
        return RiderDashboard();
      // no default needed – switch is exhaustive
    }
  }
}