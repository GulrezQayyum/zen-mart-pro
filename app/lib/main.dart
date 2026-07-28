import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Add this import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/fcm_service.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/splash_screen_animated.dart';
import 'widgets/zen_mart_buttons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Force sign out on every launch → always show login screen
  await FirebaseAuth.instance.signOut();

  // await FCMService().initializeFCM();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zen Mart Pro',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      darkTheme: _buildDarkTheme(), // Optional: dark mode
      themeMode: ThemeMode.light,
      home: const SplashScreenAnimated(),
    );
  }

  // Light Theme
  static ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Primary & Secondary Colors
      primaryColor: ZenMartColors.tealPrimary,
      scaffoldBackgroundColor: ZenMartColors.darkBg,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: ZenMartColors.tealPrimary,
        secondary: ZenMartColors.tealAccent,
        tertiary: ZenMartColors.greenAccent,
        surface: ZenMartColors.white,
        background: ZenMartColors.darkBg,
        onPrimary: ZenMartColors.white,
        onSecondary: ZenMartColors.white,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: ZenMartColors.tealPrimary,
        foregroundColor: ZenMartColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ZenMartColors.white,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: ZenMartColors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: ZenMartColors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ZenMartColors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ZenMartColors.textSecondary,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZenMartColors.darkBgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ZenMartColors.tealAccent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ZenMartColors.tealAccent.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ZenMartColors.tealAccent,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          color: ZenMartColors.textSecondary,
        ),
        hintStyle: TextStyle(
          color: ZenMartColors.textMuted,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZenMartColors.tealPrimary,
          foregroundColor: ZenMartColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZenMartColors.tealAccent,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ZenMartColors.tealPrimary,
        foregroundColor: ZenMartColors.white,
      ),
    );
  }

  // Dark Theme (optional)
  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: ZenMartColors.tealAccent,
      scaffoldBackgroundColor: ZenMartColors.darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: ZenMartColors.darkBg,
        foregroundColor: ZenMartColors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
