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
      // Each step is individually fault-tolerant so runApp is always reached.
      await _initFirebase();
      await _initHive();
      final sharedPrefs = await _initSharedPrefs();

      if (!kDebugMode && _firebaseInitialized) {
        unawaited(FirebaseAnalytics.instance.logAppOpen());
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
  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
    await Future.wait([
      Hive.openBox<dynamic>('settings'),
      Hive.openBox<dynamic>('study_cache'),
      Hive.openBox<dynamic>('user_cache'),
    ]);
  } catch (e) {
    debugPrint('[Hive] Init skipped: $e');
  }
}

Future<SharedPreferences> _initSharedPrefs() async {
  try {
    return await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('[SharedPrefs] Init failed, using in-memory fallback: $e');
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }
}
