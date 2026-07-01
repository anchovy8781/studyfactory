import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Real-time head-to-head study battle backed by Firestore.
///
/// Two users join a battle room and study; each writes their live elapsed
/// seconds to the shared doc, so both see the competition update in real time.
/// When the timer ends, whoever studied longer wins.
class BattleService {
  BattleService._();
  static final BattleService instance = BattleService._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('battles');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<String> _myName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '익명';
    final dn = user.displayName?.trim();
    if (dn != null && dn.isNotEmpty) return dn;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final nick = (doc.data()?['nickname'] as String?)?.trim();
      if (nick != null && nick.isNotEmpty) return nick;
    } catch (_) {}
    return user.email?.split('@').first ?? '익명';
  }

  /// Create a battle room (waiting for an opponent).
  Future<String> createBattle({required int durationMin}) async {
    final uid = _uid;
    if (uid == null) throw '로그인이 필요합니다.';
    final name = await _myName();
    final doc = await _col.add({
      'hostUid': uid,
      'hostName': name,
      'hostSeconds': 0,
      'guestUid': null,
      'guestName': null,
      'guestSeconds': 0,
      'durationMin': durationMin,
      'status': 'waiting',
      'startedAt': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Join a waiting battle as the guest and start it.
  Future<void> joinBattle(String id) async {
    final uid = _uid;
    if (uid == null) throw '로그인이 필요합니다.';
    final name = await _myName();
    final ref = _col.doc(id);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) throw '대결방을 찾을 수 없습니다.';
      if (data['status'] != 'waiting') throw '이미 시작되었거나 종료된 대결입니다.';
      if (data['hostUid'] == uid) throw '자신의 방에는 참가할 수 없습니다.';
      tx.update(ref, {
        'guestUid': uid,
        'guestName': name,
        'status': 'active',
        'startedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Write my live elapsed seconds to the shared doc.
  Future<void> updateProgress(String id,
      {required bool isHost, required int seconds}) async {
    try {
      await _col.doc(id).update(
          {isHost ? 'hostSeconds' : 'guestSeconds': seconds});
    } catch (_) {/* best-effort real-time sync */}
  }

  Future<void> endBattle(String id) async {
    try {
      await _col.doc(id).update({'status': 'ended'});
    } catch (_) {}
  }

  /// Cancel a waiting room (host only).
  Future<void> cancelBattle(String id) async {
    try {
      await _col.doc(id).delete();
    } catch (_) {}
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watch(String id) =>
      _col.doc(id).snapshots();

  /// Open rooms waiting for an opponent.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchOpen() {
    return _col
        .where('status', isEqualTo: 'waiting')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((s) => s.docs);
  }
}
