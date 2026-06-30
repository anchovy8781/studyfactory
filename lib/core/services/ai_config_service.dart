import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Syncs the Gemini API key from a central Firestore document so users never
/// see or enter it.
///
/// Put the key once in Firestore:
///   collection `config` → document `ai` → field `geminiApiKey` = "AQ.Ab8..."
///
/// The app reads it (best-effort) and caches it in secure storage under the
/// key every AI screen already reads, so all AI tools work automatically.
class AiConfigService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keySlot = 'claude_api_key';

  /// Fetch the server-managed key and cache it locally. Safe to call often.
  static Future<void> syncKey() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('ai')
          .get();
      final key = doc.data()?['geminiApiKey'] as String?;
      if (key != null && key.trim().isNotEmpty) {
        await _storage.write(key: _keySlot, value: key.trim());
      }
    } catch (e) {
      debugPrint('[AiConfig] key sync skipped: $e');
    }
  }
}
