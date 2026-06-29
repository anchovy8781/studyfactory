import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:studyverse/admin/admin_login_screen.dart';
import 'package:studyverse/admin/admin_dashboard_screen.dart';

const _adminPrimary = Color(0xFF1A73E8);

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyVerse Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _adminPrimary,
          primary: _adminPrimary,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        fontFamily: 'Pretendard',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A2E),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const _AdminGate(),
    );
  }
}

/// Routes between login and dashboard based on Firebase auth state.
class _AdminGate extends StatelessWidget {
  const _AdminGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const AdminDashboardScreen();
        }
        return const AdminLoginScreen();
      },
    );
  }
}
