import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final List<_Suggestion> _suggestions = const [
    _Suggestion(
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFFF6B35),
      text: '회로이론 복습이 필요해요.',
      priority: '높음',
    ),
    _Suggestion(
      icon: Icons.info_outline_rounded,
      color: Color(0xFF1A73E8),
      text: '25분 뒤 짧은 휴식을 추천해요.',
      priority: '보통',
    ),
    _Suggestion(
      icon: Icons.lightbulb_outline_rounded,
      color: Color(0xFFFFB300),
      text: '오늘 전기기사 문제 10개를 더 풀어보세요.',
      priority: '보통',
    ),
    _Suggestion(
      icon: Icons.trending_up_rounded,
      color: Color(0xFF4CAF50),
      text: '이번 주 집중도가 지난 주보다 12% 올랐어요!',
      priority: '낮음',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('AI 공부 코치', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingCard(),
            const SizedBox(height: 16),
            _buildAnalysisCard(),
            const SizedBox(height: 16),
            _buildWeeklyGoalCard(),
            const SizedBox(height: 16),
            _buildSuggestionsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Greeting card ────────────────────────────────────────────────────────
  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF4A90D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘의 공부 분석이에요!',
                    style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('김스터디님, 오늘도 열심히\n공부하고 있네요 🎉',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '계획 보기',
                      style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Dog mascot circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white38, width: 2),
            ),
            child: const Center(
              child: Text('🐶', style: TextStyle(fontSize: 40)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  // ── Analysis card ────────────────────────────────────────────────────────
  Widget _buildAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('오늘의 분석',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          // Focus score
          _buildAnalysisMetric(
            label: '집중도',
            value: '87점',
            progress: 0.87,
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.star_rounded,
            iconColor: AppColors.warning,
            label: '가장 많이 공부한 과목',
            value: '전기기사',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.psychology_alt_rounded,
            iconColor: AppColors.error,
            label: '취약 과목',
            value: '회로이론',
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 14),
          Text('AI 추천',
              style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _buildRecommendRow(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFF6B35),
            text: '회로이론 복습이 필요해요.',
          ),
          const SizedBox(height: 8),
          _buildRecommendRow(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.primary,
            text: '25분 뒤 짧은 휴식을 추천해요.',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildAnalysisMetric({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            Text(value,
                style: AppTextStyles.titleSmall.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildRecommendRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  // ── Weekly goal card ─────────────────────────────────────────────────────
  Widget _buildWeeklyGoalCard() {
    const goalHours = 30.0;
    const doneHours = 25.0;
    final progress = doneHours / goalHours;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text('이번 주 목표',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text('주간 순공 시간 목표',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${doneHours.toInt()}시간',
                  style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('/ ${goalHours.toInt()}시간',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toInt()}% 달성',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
              Text('목표까지 5시간 남았어요',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  // ── Suggestions section ──────────────────────────────────────────────────
  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI 맞춤 제안',
            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...List.generate(_suggestions.length, (i) {
          final s = _suggestions[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: s.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(s.icon, color: s.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(s.text,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _priorityColor(s.priority).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.priority,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: _priorityColor(s.priority), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ).animate().slideX(begin: 0.1, duration: 300.ms, delay: (i * 60).ms).fadeIn(),
          );
        }),
      ],
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case '높음':
        return AppColors.error;
      case '보통':
        return AppColors.primary;
      default:
        return AppColors.success;
    }
  }
}

class _Suggestion {
  final IconData icon;
  final Color color;
  final String text;
  final String priority;

  const _Suggestion({
    required this.icon,
    required this.color,
    required this.text,
    required this.priority,
  });
}
