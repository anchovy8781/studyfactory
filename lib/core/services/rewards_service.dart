import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralised points economy, all backed by Firestore.
///
/// - 첫 가입 보상 500p (회원가입 시 AuthRepository 처리)
/// - 추천인: 양쪽 각 500p (24시간 이내)
/// - 공부 10분당 5p (집중 점수 85점 이상)
/// - 연속 학습 매일 15p
class RewardsService {
  RewardsService._();
  static final RewardsService instance = RewardsService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  User? get _user => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>>? get _meDoc {
    final uid = _user?.uid;
    return uid == null ? null : _db.collection('users').doc(uid);
  }

  // ── Referral ───────────────────────────────────────────────────────────────

  /// Redeem an inviter's referral code. Both sides get 500p. Throws on error.
  Future<void> redeemReferral(String code) async {
    final me = _meDoc;
    final user = _user;
    if (me == null || user == null) throw '로그인이 필요합니다.';
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) throw '추천인 코드를 입력해 주세요.';

    final myDoc = await me.get();
    final myData = myDoc.data() ?? {};
    if ((myData['referredBy']) != null) {
      throw '이미 추천인 코드를 입력했습니다.';
    }
    if (myData['referralCode'] == normalized) {
      throw '본인 코드는 입력할 수 없습니다.';
    }
    // 24-hour window from account creation.
    final created = user.metadata.creationTime;
    if (created != null &&
        DateTime.now().difference(created) > const Duration(hours: 24)) {
      throw '추천인 코드는 가입 후 24시간 이내에만 입력할 수 있습니다.';
    }

    final codeDoc =
        await _db.collection('referralCodes').doc(normalized).get();
    if (!codeDoc.exists) throw '존재하지 않는 추천인 코드입니다.';
    final inviterUid = codeDoc.data()?['uid'] as String?;
    if (inviterUid == user.uid) throw '본인 코드는 입력할 수 없습니다.';

    // Reward myself immediately (own doc).
    await me.update({
      'points': FieldValue.increment(500),
      'referredBy': inviterUid,
    });
    // Queue the inviter's reward (they claim it on next app open).
    await _db.collection('referralCodes').doc(normalized).update({
      'pending': FieldValue.increment(1),
    });
  }

  /// Inviter claims any pending referral rewards (called on app open).
  Future<void> claimReferralRewards() async {
    final me = _meDoc;
    if (me == null) return;
    try {
      final myDoc = await me.get();
      final myCode = myDoc.data()?['referralCode'] as String?;
      if (myCode == null) return;
      final codeRef = _db.collection('referralCodes').doc(myCode);
      await _db.runTransaction((tx) async {
        final snap = await tx.get(codeRef);
        final pending = (snap.data()?['pending'] as num?)?.toInt() ?? 0;
        if (pending <= 0) return;
        tx.update(me, {'points': FieldValue.increment(pending * 500)});
        tx.update(codeRef, {'pending': 0});
      });
    } catch (_) {/* best-effort */}
  }

  // ── Study reward + time tracking ─────────────────────────────────────────

  /// Records a finished study session: adds study time to net/total hours and
  /// awards 5p per completed 10-minute block when avg focus ≥ 85.
  /// Returns the points awarded (for UI feedback).
  Future<int> recordStudySession({
    required int minutes,
    required double avgFocusScore,
  }) async {
    final me = _meDoc;
    if (me == null || minutes <= 0) return 0;

    final hours = minutes / 60.0;
    final blocks = minutes ~/ 10;
    final awarded = (avgFocusScore >= 85 && blocks > 0) ? blocks * 5 : 0;

    await me.update({
      'todayStudyHours': FieldValue.increment(hours),
      'totalStudyHours': FieldValue.increment(hours),
      if (awarded > 0) 'points': FieldValue.increment(awarded),
    });
    return awarded;
  }

  // ── Daily streak ───────────────────────────────────────────────────────────

  /// Awards 15p once per day and advances the streak. Returns true if awarded.
  Future<bool> checkDailyStreak() async {
    final me = _meDoc;
    if (me == null) return false;
    try {
      final doc = await me.get();
      final data = doc.data() ?? {};
      final today = _dayKey(DateTime.now());
      final last = data['lastStreakDate'] as String?;
      if (last == today) return false; // already counted today

      final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
      final currentStreak = (data['streakDays'] as num?)?.toInt() ?? 0;
      final newStreak = (last == yesterday) ? currentStreak + 1 : 1;

      await me.update({
        'streakDays': newStreak,
        'lastStreakDate': today,
        'points': FieldValue.increment(15),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
