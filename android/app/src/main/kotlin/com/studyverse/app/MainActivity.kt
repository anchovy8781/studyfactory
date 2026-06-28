package com.studyverse.app

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * Main entry point for the StudyVerse Android app.
 *
 * Uses [FlutterFragmentActivity] instead of [FlutterActivity] because:
 *  - [local_auth] requires Fragment support for biometric prompts.
 *  - Some camera plugins also work better with Fragment back-stack support.
 */
class MainActivity : FlutterFragmentActivity()
