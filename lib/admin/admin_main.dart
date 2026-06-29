import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:studyverse/admin/admin_app.dart';
import 'package:studyverse/firebase_options.dart';

/// Entry point for the StudyVerse Admin web panel (PC + mobile browser).
///
/// Build:  flutter build web -t lib/admin/admin_main.dart --release
/// Run:    flutter run -d chrome -t lib/admin/admin_main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[AdminWeb] Firebase init: $e');
  }
  runApp(const AdminApp());
}
