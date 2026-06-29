import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:studyverse/admin/admin_app.dart';

/// Entry point for the StudyVerse Admin web panel (PC + mobile browser).
///
/// Build:  flutter build web -t lib/admin/admin_main.dart --release
/// Run:    flutter run -d chrome -t lib/admin/admin_main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Web Firebase config is supplied via web/index.html; if missing the
    // app still renders and surfaces a clear error on sign-in.
    debugPrint('[AdminWeb] Firebase init: $e');
  }
  runApp(const AdminApp());
}
