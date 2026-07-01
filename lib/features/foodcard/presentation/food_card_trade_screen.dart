import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/features/foodcard/data/food_card_service.dart';
import 'package:studyverse/features/foodcard/data/food_cards.dart';

/// Peer-to-peer food card trading (send / receive).
class FoodCardTradeScreen extends StatelessWidget {
  const FoodCardTradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          centerTitle: true,
          title: Text('카드 교환', style: AppTextStyles.titleLarge),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [Tab(text: '보내기'), Tab(text: '받은/보낸 교환')],
          ),
        ),
        body: const TabBarView(
          children: [_SendTab(), _TradesTab()],
        ),
      ),
    );
  }
}

class _SendTab extends StatefulWidget {
  const _SendTab();
  @override
  State<_SendTab> createState() => _SendTabState();
}

class _SendTabState extends State<_SendTab> {
  final _nickCtrl = TextEditingController();
  int? _selectedCard;
  bool _sending = false;

  @override
  void dispose() {
    _nickCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_selectedCard == null || _nickCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FoodCardService.instance
          .sendTrade(cardId: _selectedCard!, toNickname: _nickCtrl.text);
      messenger.showSnackBar(const SnackBar(
        content: Text('교환 요청을 보냈습니다. 상대가 수락하면 전달됩니다.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {
        _selectedCard = null;
        _nickCtrl.clear();
      });
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('$e'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, int>>(
      stream: FoodCardService.instance.watchCollection(),
      builder: (context, snapshot) {
        final owned = snapshot.data ?? const {};
        final ids = owned.keys.toList()..sort();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _nickCtrl,
              decoration: const InputDecoration(
                labelText: '받는 사람 닉네임',
                hintText: '상대의 닉네임을 입력하세요',
                prefixIcon: Icon(Icons.person_search_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('보낼 카드 선택', style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            if (ids.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('보유한 카드가 없어요. 먼저 카드를 뽑아보세요!',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: ids.map((id) {
                  final card = foodCardById(id);
                  final sel = _selectedCard == id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCard = id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel ? AppColors.primary : AppColors.border,
                            width: sel ? 2 : 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(card.emoji, style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 2),
                          Text('x${owned[id]}',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_sending || _selectedCard == null) ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: Text(_sending ? '보내는 중...' : '교환 보내기'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TradesTab extends StatelessWidget {
  const _TradesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('받은 교환', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          stream: FoodCardService.instance.watchIncomingTrades(),
          builder: (context, snapshot) {
            final docs = snapshot.data ?? const [];
            if (docs.isEmpty) return _empty('받은 교환이 없어요.');
            return Column(
              children: docs.map((d) {
                final m = d.data();
                final card = foodCardById((m['cardId'] as num).toInt());
                return _tradeCard(
                  emoji: card.emoji,
                  title: '${m['fromName'] ?? '누군가'} 님이 ${card.name} 보냄',
                  actionLabel: '수락',
                  actionColor: AppColors.success,
                  onAction: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await FoodCardService.instance.acceptTrade(d.id);
                      messenger.showSnackBar(SnackBar(
                        content: Text('${card.name} 카드를 받았습니다! 🎉'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ));
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(
                          content: Text('$e'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating));
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        Text('보낸 교환 (대기 중)', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          stream: FoodCardService.instance.watchOutgoingTrades(),
          builder: (context, snapshot) {
            final docs = snapshot.data ?? const [];
            if (docs.isEmpty) return _empty('보낸 교환이 없어요.');
            return Column(
              children: docs.map((d) {
                final m = d.data();
                final card = foodCardById((m['cardId'] as num).toInt());
                return _tradeCard(
                  emoji: card.emoji,
                  title: '${m['toNickname'] ?? '상대'} 에게 ${card.name} 보냄',
                  actionLabel: '취소',
                  actionColor: AppColors.error,
                  onAction: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await FoodCardService.instance.cancelTrade(d.id);
                      messenger.showSnackBar(const SnackBar(
                        content: Text('교환을 취소하고 카드를 돌려받았습니다.'),
                        behavior: SnackBarBehavior.floating,
                      ));
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(
                          content: Text('$e'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating));
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _tradeCard({
    required String emoji,
    required String title,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: actionColor),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _empty(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(text,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary)),
      );
}
