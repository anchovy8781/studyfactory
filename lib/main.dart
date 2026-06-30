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
import 'package:studyverse/firebase_options.dart';
import 'package:studyverse/core/services/notification_service.dart';

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

  // Edge-to-edge (Android 10+ native support).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Forward Flutter framework errors before runApp so the handler is always set.
  FlutterError.onError = (details) {
    debugPrint('[Flutter] ${details.exceptionAsString()}');
    if (!kDebugMode && _firebaseInitialized) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  // Run everything inside a guarded zone so async errors are captured too.
  await runZonedGuarded(
    () async {
      // Each step is individually fault-tolerant so runApp is always reached.
      await _initFirebase();
      await _initHive();
      final sharedPrefs = await _initSharedPrefs();
      unawaited(NotificationService.instance.init());

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
      debugPrint('[main] Uncaught error: $error\n$stack');
      if (!kDebugMode && _firebaseInitialized) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
    },
  );
}

// ── Initialisation helpers ────────────────────────────────────────────────────

bool _firebaseInitialized = false;

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseInitialized = true;

    if (!kDebugMode) {
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    }
  } catch (e) {
    // Placeholder / missing google-services.json in debug — skip Firebase.
    debugPrint('[Firebase] Init skipped: $e');
  }
}

Future<void> _initHive() async {
  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
    await _openHiveBoxes();
  } catch (e) {
    debugPrint('[Hive] Init failed ($e), attempting recovery...');
    try {
      // Delete potentially corrupted box files and retry once
      for (final name in ['settings', 'study_cache', 'user_cache']) {
        await Hive.deleteBoxFromDisk(name);
      }
      await _openHiveBoxes();
      debugPrint('[Hive] Recovery succeeded');
    } catch (e2) {
      debugPrint('[Hive] Recovery failed: $e2 — running without persistence');
    }
  }
}

Future<void> _openHiveBoxes() => Future.wait([
      Hive.openBox<dynamic>('settings'),
      Hive.openBox<dynamic>('study_cache'),
      Hive.openBox<dynamic>('user_cache'),
    ]);

Future<SharedPreferences> _initSharedPrefs() async {
  try {
    return await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('[SharedPrefs] Init failed, using in-memory fallback: $e');
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }
}
