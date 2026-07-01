import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyverse/core/services/rewards_service.dart';
import 'package:studyverse/features/foodcard/data/food_cards.dart';

class FoodCardService {
  FoodCardService._();
  static final FoodCardService instance = FoodCardService._();

  static const drawCost = 100; // 1회 뽑기 비용

  final _rng = Random();

  DocumentReference<Map<String, dynamic>>? get _me {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null
        ? null
        : FirebaseFirestore.instance.collection('users').doc(uid);
  }

  /// Rarity probabilities.
  static const _weights = {
    'legendary': 3,
    'epic': 12,
    'rare': 30,
    'common': 55,
  };

  String _rollRarity() {
    final total = _weights.values.reduce((a, b) => a + b);
    var r = _rng.nextInt(total);
    for (final e in _weights.entries) {
      if (r < e.value) return e.key;
      r -= e.value;
    }
    return 'common';
  }

  /// Draw one card. Deducts points, adds the card to the collection.
  /// Throws on insufficient points / not signed in.
  Future<FoodCard> draw() async {
    final me = _me;
    if (me == null) throw '로그인이 필요합니다.';

    final drawn = await FirebaseFirestore.instance.runTransaction<FoodCard>((tx) async {
      final snap = await tx.get(me);
      final points = (snap.data()?['points'] as num?)?.toInt() ?? 0;
      if (points < drawCost) {
        throw '포인트가 부족합니다. (필요: $drawCost P)';
      }
      final rarity = _rollRarity();
      final pool = foodCards.where((c) => c.rarity == rarity).toList();
      final card = pool[_rng.nextInt(pool.length)];

      tx.update(me, {
        'points': points - drawCost,
        'foodCards.${card.id}': FieldValue.increment(1),
      });
      return card;
    });

    await RewardsService.instance.logPoints(-drawCost, '푸드카드 뽑기');
    return drawn;
  }

  // ── Trading ────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _trades =>
      FirebaseFirestore.instance.collection('trades');

  /// Resolve a recipient's uid from their nickname via the public leaderboard.
  Future<String?> _uidByNickname(String nickname) async {
    final snap = await FirebaseFirestore.instance
        .collection('leaderboard')
        .where('nickname', isEqualTo: nickname.trim())
        .limit(1)
        .get();
    return snap.docs.isEmpty ? null : snap.docs.first.id;
  }

  /// Send [cardId] to another user by nickname. The card is escrowed (removed
  /// from the sender now) and delivered when the recipient accepts.
  Future<void> sendTrade({
    required int cardId,
    required String toNickname,
  }) async {
    final me = _me;
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (me == null || myUid == null) throw '로그인이 필요합니다.';

    final toUid = await _uidByNickname(toNickname);
    if (toUid == null) {
      throw '상대를 찾을 수 없습니다. (상대가 공부 기록이 있어야 검색됩니다)';
    }
    if (toUid == myUid) throw '자신에게는 보낼 수 없습니다.';

    final myName = await resolveTraderName();
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(me);
      final have = ((snap.data()?['foodCards'] as Map?)?['$cardId'] as num?)
              ?.toInt() ??
          0;
      if (have <= 0) throw '보유하지 않은 카드입니다.';
      tx.update(me, {'foodCards.$cardId': FieldValue.increment(-1)});
      tx.set(_trades.doc(), {
        'fromUid': myUid,
        'fromName': myName,
        'toUid': toUid,
        'toNickname': toNickname.trim(),
        'cardId': cardId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Recipient accepts a pending trade → card is added to their collection.
  Future<void> acceptTrade(String tradeId) async {
    final me = _me;
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (me == null || myUid == null) throw '로그인이 필요합니다.';
    final ref = _trades.doc(tradeId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final t = await tx.get(ref);
      final data = t.data();
      if (data == null || data['status'] != 'pending') throw '이미 처리된 교환입니다.';
      if (data['toUid'] != myUid) throw '받을 권한이 없습니다.';
      final cardId = (data['cardId'] as num).toInt();
      tx.update(me, {'foodCards.$cardId': FieldValue.increment(1)});
      tx.update(ref, {'status': 'completed'});
    });
  }

  /// Sender cancels a pending trade → the escrowed card is returned.
  Future<void> cancelTrade(String tradeId) async {
    final me = _me;
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (me == null || myUid == null) throw '로그인이 필요합니다.';
    final ref = _trades.doc(tradeId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final t = await tx.get(ref);
      final data = t.data();
      if (data == null || data['status'] != 'pending') throw '이미 처리된 교환입니다.';
      if (data['fromUid'] != myUid) throw '취소 권한이 없습니다.';
      final cardId = (data['cardId'] as num).toInt();
      tx.update(me, {'foodCards.$cardId': FieldValue.increment(1)});
      tx.update(ref, {'status': 'cancelled'});
    });
  }

  Future<String> resolveTraderName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '익명';
    final dn = user.displayName?.trim();
    if (dn != null && dn.isNotEmpty) return dn;
    try {
      final doc = await _me!.get();
      final nick = (doc.data()?['nickname'] as String?)?.trim();
      if (nick != null && nick.isNotEmpty) return nick;
    } catch (_) {}
    return user.email?.split('@').first ?? '익명';
  }

  /// Incoming pending trades for the current user.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchIncomingTrades() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _trades
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs);
  }

  /// Outgoing pending trades the current user has sent.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchOutgoingTrades() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _trades
        .where('fromUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs);
  }

  /// Stream of owned card counts {cardId: count}.
  Stream<Map<int, int>> watchCollection() {
    final me = _me;
    if (me == null) return const Stream.empty();
    return me.snapshots().map((doc) {
      final raw = (doc.data()?['foodCards'] as Map?) ?? const {};
      final out = <int, int>{};
      raw.forEach((k, v) {
        final id = int.tryParse(k.toString());
        final n = (v as num?)?.toInt() ?? 0;
        if (id != null && n > 0) out[id] = n;
      });
      return out;
    });
  }
}
