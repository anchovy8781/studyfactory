import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studyverse/core/constants/app_strings.dart';
import 'package:studyverse/core/router/app_router.dart';
import 'package:studyverse/core/theme/app_theme.dart';
import 'package:studyverse/core/theme/dark_theme.dart';

/// Root application widget.
///
/// Wires together:
///  - [GoRouter] for navigation (via [appRouterProvider])
///  - Light + dark [ThemeData] from the StudyVerse design system
///  - Korean localisation
///  - Error boundary for uncaught widget errors
class StudyVerseApp extends ConsumerWidget {
  const StudyVerseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // ── Router ─────────────────────────────────────────────────────────────
      routerConfig: router,

      // ── Meta ───────────────────────────────────────────────────────────────
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: DarkTheme.dark,
      themeMode: ThemeMode.system,

      // ── Localisation ───────────────────────────────────────────────────────
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Global builder (MediaQuery, etc.) ──────────────────────────────────
      builder: (context, child) {
        // Prevent text scaling beyond 1.3× to protect UI layouts.
        final mediaQuery = MediaQuery.of(context);
        final clamped = mediaQuery.copyWith(
          textScaler: mediaQuery.textScaler.clamp(
            minScaleFactor: 0.8,
            maxScaleFactor: 1.3,
          ),
        );
        return MediaQuery(
          data: clamped,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
