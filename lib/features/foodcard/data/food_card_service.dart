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
