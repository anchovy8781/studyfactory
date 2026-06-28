import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------
final _rewards = [
  _RewardItem(
    emoji: '☕',
    name: '스타벅스 아메리카노',
    description: '스타벅스 톨 사이즈 아메리카노',
    points: 4100,
    color: const Color(0xFF00704A),
  ),
  _RewardItem(
    emoji: '🎫',
    name: '윤리형 상품권',
    description: '전국 서점 사용 가능',
    points: 10000,
    color: const Color(0xFF1A73E8),
  ),
  _RewardItem(
    emoji: '🍕',
    name: '피자헛 기프티콘',
    description: '미디엄 피자 1판 교환권',
    points: 15000,
    color: const Color(0xFFE53935),
  ),
  _RewardItem(
    emoji: '🎮',
    name: '구글 플레이 기프트카드',
    description: '5,000원 상당',
    points: 5000,
    color: const Color(0xFF34A853),
  ),
];

final _historyItems = [
  _HistoryItem(
    icon: Icons.add_circle_rounded,
    iconColor: AppColors.success,
    title: '7일 연속 학습 보너스',
    points: '+500P',
    date: '2024.05.20',
    isEarn: true,
  ),
  _HistoryItem(
    icon: Icons.remove_circle_rounded,
    iconColor: AppColors.error,
    title: '스타벅스 아메리카노 교환',
    points: '-4,100P',
    date: '2024.05.18',
    isEarn: false,
  ),
  _HistoryItem(
    icon: Icons.add_circle_rounded,
    iconColor: AppColors.success,
    title: '30시간 달성 보너스',
    points: '+1,000P',
    date: '2024.05.15',
    isEarn: true,
  ),
  _HistoryItem(
    icon: Icons.add_circle_rounded,
    iconColor: AppColors.success,
    title: '출석 체크 보너스',
    points: '+50P',
    date: '2024.05.14',
    isEarn: true,
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('리워드', style: AppTextStyles.titleLarge),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('교환 내역',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointCard(),
            const SizedBox(height: 20),
            _buildRewardsSection(),
            const SizedBox(height: 20),
            _buildHistorySection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Points card ──────────────────────────────────────────────────────────
  Widget _buildPointCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('보유 포인트',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('12,450',
                  style: AppTextStyles.displaySmall.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('P',
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white70)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('포인트 충전'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('내역 보기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Rewards section ──────────────────────────────────────────────────────
  Widget _buildRewardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('추천 리워드',
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
            TextButton(
              onPressed: () {},
              child: Text('전체 보기',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: List.generate(_rewards.length, (i) {
            return _RewardCard(reward: _rewards[i], index: i);
          }),
        ),
      ],
    );
  }

  // ── History section ──────────────────────────────────────────────────────
  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('포인트 내역',
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
            TextButton(
              onPressed: () {},
              child: Text('전체 보기',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: List.generate(_historyItems.length, (i) {
              final item = _historyItems[i];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: item.iconColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: item.iconColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600)),
                              Text(item.date,
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Text(
                          item.points,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: item.isEarn ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < _historyItems.length - 1)
                    const Divider(height: 1, color: AppColors.divider, indent: 66),
                ],
              );
            }),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reward card widget
// ---------------------------------------------------------------------------
class _RewardCard extends StatefulWidget {
  const _RewardCard({required this.reward, required this.index});

  final _RewardItem reward;
  final int index;

  @override
  State<_RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<_RewardCard> {
  bool _exchanged = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.reward;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: r.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(r.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 10),
          Text(r.name,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(r.description,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text('${r.points}P',
              style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() => _exchanged = !_exchanged),
              style: TextButton.styleFrom(
                backgroundColor: _exchanged ? AppColors.surfaceVariant : r.color.withOpacity(0.12),
                foregroundColor: _exchanged ? AppColors.textSecondary : r.color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              child: Text(_exchanged ? '교환 완료' : '교환하기'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (widget.index * 60).ms).scale(begin: const Offset(0.95, 0.95));
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------
class _RewardItem {
  final String emoji;
  final String name;
  final String description;
  final int points;
  final Color color;

  const _RewardItem({
    required this.emoji,
    required this.name,
    required this.description,
    required this.points,
    required this.color,
  });
}

class _HistoryItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String points;
  final String date;
  final bool isEarn;

  const _HistoryItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.points,
    required this.date,
    required this.isEarn,
  });
}
