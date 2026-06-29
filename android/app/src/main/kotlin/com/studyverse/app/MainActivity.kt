package com.studyverse.app

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * Main entry point for the StudyVerse Android app.
 *
 * Uses [FlutterFragmentActivity] for biometric prompt support (local_auth).
 * WindowCompat.setDecorFitsSystemWindows(false) enables true edge-to-edge
 * on Android 10+ (API 29+), letting Flutter draw behind the status/nav bars.
 */
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
