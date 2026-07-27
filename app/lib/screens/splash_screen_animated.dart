// lib/screens/splash_screen_animated.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../screens/auth_gate.dart';

class SplashScreenAnimated extends StatefulWidget {
  const SplashScreenAnimated({Key? key}) : super(key: key);

  @override
  State<SplashScreenAnimated> createState() => _SplashScreenAnimatedState();
}

class _SplashScreenAnimatedState extends State<SplashScreenAnimated> {
  @override
  void initState() {
    super.initState();
    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF0F1B2E), // your dark background
        child: Center(
          child: Image.asset(
            'assets/images/splash.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}