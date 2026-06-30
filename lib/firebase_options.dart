import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for StudyVerse (project: studyfactory-3a14d).
///
/// Used by both the mobile app and the admin web panel. The web config is the
/// real project config; on Android/iOS the same project credentials are used
/// so email/password auth and Firestore work immediately. For full native
/// features (Google Sign-In, push), register an Android app in the Firebase
/// console and drop in google-services.json.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBY099ueNESXPeERP1vKmVdbFGQYMCksIk',
    appId: '1:523054850515:web:be2f71b2e3984ea37e0f26',
    messagingSenderId: '523054850515',
    projectId: 'studyfactory-3a14d',
    authDomain: 'studyfactory-3a14d.firebaseapp.com',
    storageBucket: 'studyfactory-3a14d.firebasestorage.app',
    measurementId: 'G-1R6Z2QSNYV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCfmpUdkJjfsnKR7xfDE-wGVregekRw2Uw',
    appId: '1:523054850515:android:05d6fad2d630a0a87e0f26',
    messagingSenderId: '523054850515',
    projectId: 'studyfactory-3a14d',
    storageBucket: 'studyfactory-3a14d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCfmpUdkJjfsnKR7xfDE-wGVregekRw2Uw',
    appId: '1:523054850515:android:05d6fad2d630a0a87e0f26',
    messagingSenderId: '523054850515',
    projectId: 'studyfactory-3a14d',
    storageBucket: 'studyfactory-3a14d.firebasestorage.app',
  );
}
