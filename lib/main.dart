import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studyverse/app.dart';

/// SharedPreferences singleton provider (injected via ProviderScope override).
final sharedPreferencesProvider =
    Provider<SharedPreferences>((_) => throw UnimplementedError());

Future<void> main() async {
  // Ensure Flutter engine is ready before calling platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent system bars for an edge-to-edge look.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Run everything inside a guarded zone so async errors are captured too.
  await runZonedGuarded(
    () async {
      // ── Parallel initialisation ─────────────────────────────────────────
      final results = await Future.wait<dynamic>([
        _initFirebase(),
        _initHive(),
        SharedPreferences.getInstance(),
      ]);

      final sharedPrefs = results[2] as SharedPreferences;

      // ── Analytics: first-open event ────────────────────────────────────
      if (!kDebugMode && _firebaseInitialized) {
        unawaited(
          FirebaseAnalytics.instance.logAppOpen(),
        );
      }

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          ],
          child: const StudyVerseApp(),
        ),
      );
    },
    (error, stack) {
      // Forward all uncaught errors to Crashlytics in release mode.
      if (!kDebugMode && _firebaseInitialized) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } else {
        debugPrint('[main] Uncaught error: $error\n$stack');
      }
    },
  );
}

// ── Initialisation helpers ────────────────────────────────────────────────────

bool _firebaseInitialized = false;

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    _firebaseInitialized = true;

    // Forward Flutter framework errors to Crashlytics.
    if (!kDebugMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // Disable Crashlytics data collection in debug mode.
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    // Analytics opt-in defaults to true; disable in debug.
    await FirebaseAnalytics.instance
        .setAnalyticsCollectionEnabled(!kDebugMode);
  } catch (e) {
    // Placeholder / missing google-services.json in debug — skip Firebase.
    debugPrint('[Firebase] Init skipped: $e');
  }
}

Future<void> _initHive() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  // Register Hive adapters here as features are added.
  // Example: Hive.registerAdapter(StudySessionAdapter());

  // Open commonly used boxes upfront.
  await Future.wait([
    Hive.openBox<dynamic>('settings'),
    Hive.openBox<dynamic>('study_cache'),
    Hive.openBox<dynamic>('user_cache'),
  ]);
}
