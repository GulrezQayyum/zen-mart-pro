// lib/screens/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../models/user_model.dart';
import './auth/login_screen.dart';
import './admin/admin_dashboard_screen.dart';
import './vendor/vendor_dashboard_screen.dart';
import './customer/customer_home.dart';
import './rider/rider_dashboard.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch auth state (stream of Firebase User?)
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (firebaseUser) {
        // If NOT logged in, show Login Screen
        if (firebaseUser == null) {
          return const LoginScreen();
        }

        // 2. Logged in – watch user data from Firestore
        final userDataAsync = ref.watch(currentUserProvider);

        return userDataAsync.when(
          loading: () => const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading user data...'),
                ],
              ),
            ),
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
                    onPressed: () {
                      ref.invalidate(currentUserProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (appUser) {
            // If appUser is null (Firestore doc missing), show Login
            if (appUser == null) {
              return const LoginScreen();
            }

            // 3. Route based on user role
            return _buildDashboard(appUser);
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking authentication...'),
            ],
          ),
        ),
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
                onPressed: () {
                  ref.invalidate(authStateProvider);
                },
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
        return const AdminDashboard();
      case UserRole.vendor:
        return const VendorDashboard();
      case UserRole.user:
        return const CustomerHome();
      case UserRole.rider:
        return const RiderDashboard();
      default:
        return const CustomerHome();
    }
  }
}