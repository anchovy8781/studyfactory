import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/features/home/domain/models/home_model.dart';

/// Reads the signed-in user's real home data from Firestore.
///
/// No mock/dummy values — a brand-new account starts at zero. Fields that the
/// app does not track yet (today's hours, focus score, sessions) default to 0
/// until study sessions populate them.
class HomeRepository {
  HomeRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Future<HomeData> fetchHomeData() async {
    final user = _auth.currentUser;
    if (user == null) return _empty('사용자');

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      final d = doc.data();
      if (d == null) return _empty(user.displayName ?? '사용자');

      // 순공 시간은 매일 초기화: 저장된 날짜가 오늘이 아니면 0으로 표시.
      // (누적 기록은 통계(studySessions·totalStudyHours)에 그대로 보존됨)
      final now = DateTime.now();
      final todayKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final storedDay = d['todayStudyDate'] as String?;
      final rawToday = (d['todayStudyHours'] as num?)?.toDouble() ?? 0.0;
      final todayHours = storedDay == todayKey ? rawToday : 0.0;

      return HomeData(
        userNickname:
            (d['nickname'] as String?) ?? user.displayName ?? '사용자',
        todayStudyHours: todayHours,
        targetHours: (d['targetHours'] as num?)?.toDouble() ?? 5.0,
        streakDays: (d['streakDays'] as num?)?.toInt() ?? 0,
        bestStreak: (d['bestStreak'] as num?)?.toInt() ?? 0,
        points: (d['points'] as num?)?.toInt() ?? 0,
        focusScore: (d['focusScore'] as num?)?.toDouble() ?? 0.0,
        recentSessions: (d['recentSessions'] as num?)?.toInt() ?? 0,
        isStudying: (d['isStudying'] as bool?) ?? false,
      );
    } catch (_) {
      return _empty(user.displayName ?? '사용자');
    }
  }

  HomeData _empty(String nickname) => HomeData(
        userNickname: nickname,
        todayStudyHours: 0.0,
        targetHours: 5.0,
        streakDays: 0,
        bestStreak: 0,
        points: 0,
        focusScore: 0.0,
        recentSessions: 0,
        isStudying: false,
      );
}

// ── Providers ──────────────────────────────────────────────────────────────

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});
