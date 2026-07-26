import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/fcm_provider.dart';
import '../models/user_model.dart';
import 'auth/login_screen.dart';
import 'package:dashboard_app/screens/admin/admin_dashboard_screen.dart';
import 'package:dashboard_app/screens/vendor/vendor_dashboard_screen.dart';
import 'package:dashboard_app/screens/customer/customer_home.dart';
import 'package:dashboard_app/screens/rider/rider_dashboard.dart';
import 'package:dashboard_app/screens/common/home_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for changes in user profile to initialize FCM once authenticated
    ref.listen(currentUserProvider, (previous, next) {
      next.whenData((appUser) {
        if (appUser != null) {
          ref.read(fcmServiceProvider).initializeFCM(userId: appUser.uid);
        }
      });
    });

    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        return currentUser.when(
          data: (appUser) {
            if (appUser == null) {
              return const Scaffold(
                body: Center(
                  child: Text('User data not found'),
                ),
              );
            }

            // Route correctly based on the user's role (No 'const' keywords here)
            switch (appUser.role) {
              case UserRole.admin:
                return AdminDashboard();
              case UserRole.vendor:
                return VendorDashboard();
              case UserRole.user:
                return CustomerHome();
              case UserRole.rider:
                return RiderDashboard();
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