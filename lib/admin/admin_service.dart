import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A user row shown in the admin panel.
class AdminUser {
  const AdminUser({
    required this.uid,
    required this.email,
    required this.nickname,
    required this.role,
    required this.level,
    required this.points,
    required this.totalStudyHours,
    required this.streakDays,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String nickname;
  final String role;
  final int level;
  final int points;
  final double totalStudyHours;
  final int streakDays;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';

  factory AdminUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return AdminUser(
      uid: doc.id,
      email: (d['email'] as String?) ?? '',
      nickname: (d['nickname'] as String?) ?? '(이름 없음)',
      role: (d['role'] as String?) ?? 'user',
      level: (d['level'] as num?)?.toInt() ?? 1,
      points: (d['points'] as num?)?.toInt() ?? 0,
      totalStudyHours: (d['totalStudyHours'] as num?)?.toDouble() ?? 0.0,
      streakDays: (d['streakDays'] as num?)?.toInt() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Aggregate stats for the dashboard header.
class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.totalPoints,
    required this.totalStudyHours,
    required this.adminCount,
  });

  final int totalUsers;
  final int totalPoints;
  final double totalStudyHours;
  final int adminCount;
}

/// Firestore-backed admin operations. Pure backend — no local data.
class AdminService {
  AdminService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Sign in an administrator. Throws if the account is not an admin.
  Future<void> signInAdmin(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final doc = await _users.doc(cred.user!.uid).get();
    final role = doc.data()?['role'] as String?;
    if (role != 'admin') {
      await _auth.signOut();
      throw '관리자 권한이 없는 계정입니다.';
    }
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Stream<List<AdminUser>> watchUsers() {
    return _users
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AdminUser.fromDoc).toList());
  }

  Future<AdminStats> fetchStats() async {
    final snap = await _users.get();
    var points = 0;
    var hours = 0.0;
    var admins = 0;
    for (final doc in snap.docs) {
      final d = doc.data();
      points += (d['points'] as num?)?.toInt() ?? 0;
      hours += (d['totalStudyHours'] as num?)?.toDouble() ?? 0.0;
      if (d['role'] == 'admin') admins++;
    }
    return AdminStats(
      totalUsers: snap.size,
      totalPoints: points,
      totalStudyHours: hours,
      adminCount: admins,
    );
  }

  /// Promote/demote a user between 'user' and 'admin'.
  Future<void> setRole(String uid, String role) =>
      _users.doc(uid).update({'role': role});

  /// Adjust a user's points (admin moderation).
  Future<void> setPoints(String uid, int points) =>
      _users.doc(uid).update({'points': points});

  /// Soft-disable handled by removing the profile document.
  Future<void> deleteUserDoc(String uid) => _users.doc(uid).delete();
}
