import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/features/foodcard/data/food_card_service.dart';
import 'package:studyverse/features/foodcard/data/food_cards.dart';

Color rarityColor(String r) => switch (r) {
      'legendary' => const Color(0xFFFFB300),
      'epic' => const Color(0xFF9C27B0),
      'rare' => const Color(0xFF1A73E8),
      _ => const Color(0xFF9E9E9E),
    };

String rarityLabel(String r) => switch (r) {
      'legendary' => '전설',
      'epic' => '에픽',
      'rare' => '레어',
      _ => '일반',
    };

class FoodCardScreen extends StatefulWidget {
  const FoodCardScreen({super.key});

  @override
  State<FoodCardScreen> createState() => _FoodCardScreenState();
}

class _FoodCardScreenState extends State<FoodCardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('푸드카드', style: AppTextStyles.titleLarge),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: '뽑기'), Tab(text: '도감')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [_DrawTab(), _CollectionTab()],
      ),
    );
  }
}

class _DrawTab extends StatefulWidget {
  const _DrawTab();
  @override
  State<_DrawTab> createState() => _DrawTabState();
}

class _DrawTabState extends State<_DrawTab> {
  bool _drawing = false;
  FoodCard? _last;

  Future<void> _draw() async {
    setState(() => _drawing = true);
    try {
      final card = await FoodCardService.instance.draw();
      if (mounted) setState(() => _last = card);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _drawing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
      child: Column(
        children: [
          if (uid != null)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snap) {
                final p = (snap.data?.data()?['points'] as num?)?.toInt() ?? 0;
                return Text('보유 포인트: $p P',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.primary));
              },
            ),
          const SizedBox(height: AppSizes.spaceXl),
          // Result card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _last == null
                ? Container(
                    key: const ValueKey('empty'),
                    width: 200,
                    height: 260,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                        child: Text('?',
                            style: TextStyle(
                                fontSize: 64, color: AppColors.textHint))),
                  )
                : _cardView(_last!),
          ),
          const SizedBox(height: AppSizes.space2xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _drawing ? null : _draw,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: _drawing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('카드 뽑기 (${FoodCardService.drawCost}P)',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),
          Text('확률: 전설 3% · 에픽 12% · 레어 30% · 일반 55%',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _cardView(FoodCard c) {
    final color = rarityColor(c.rarity);
    return Container(
      key: ValueKey(c.id),
      width: 200,
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.18), AppColors.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(10)),
            child: Text(rarityLabel(c.rarity),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Text(c.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 12),
          Text(c.name,
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _CollectionTab extends StatelessWidget {
  const _CollectionTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, int>>(
      stream: FoodCardService.instance.watchCollection(),
      builder: (context, snapshot) {
        final owned = snapshot.data ?? const {};
        final count = owned.keys.length;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('수집: $count / ${foodCards.length}',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemCount: foodCards.length,
                itemBuilder: (context, i) {
                  final c = foodCards[i];
                  final n = owned[c.id] ?? 0;
                  final has = n > 0;
                  final color = rarityColor(c.rarity);
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: has ? color : AppColors.border,
                          width: has ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(has ? c.emoji : '🔒',
                            style: TextStyle(
                                fontSize: 34,
                                color: has ? null : AppColors.textHint)),
                        const SizedBox(height: 4),
                        Text(has ? c.name : '???',
                            style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: has
                                    ? AppColors.textPrimary
                                    : AppColors.textHint),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(rarityLabel(c.rarity),
                            style: AppTextStyles.caption.copyWith(color: color)),
                        if (n > 1)
                          Text('x$n',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
