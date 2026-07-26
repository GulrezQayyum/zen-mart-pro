import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import 'package:dashboard_app/screens/admin/admin_dashboard_screen.dart';
import 'package:dashboard_app/screens/vendor/vendor_dashboard_screen.dart';
import 'package:dashboard_app/screens/customer/customer_home.dart';
import 'package:dashboard_app/screens/rider/rider_dashboard.dart';
import '../screens/role_selector_screen.dart';

class Routes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String roleSelector = '/role-selector';
  static const String adminDashboard = '/admin-dashboard';
  static const String vendorDashboard = '/vendor-dashboard';
  static const String customerHome = '/customer-home';
  static const String riderDashboard = '/rider-dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return  MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case roleSelector:
        return MaterialPageRoute(builder: (_) => const RoleSelectorScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case vendorDashboard:
        return MaterialPageRoute(builder: (_) => const VendorDashboardScreen());
      case customerHome:
        return MaterialPageRoute(builder: (_) => const CustomerHome());
      case riderDashboard:
        return MaterialPageRoute(builder: (_) => const RiderDashboard());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}