import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';

class AiToolsScreen extends StatelessWidget {
  const AiToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('AI 학습 도구', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI 기능', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.spaceMd),
            _buildGrid(context, _aiTools),
            const SizedBox(height: AppSizes.spaceLg),
            Text('학습 도구', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSizes.spaceMd),
            _buildGrid(context, _studyTools),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<_ToolItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.spaceMd,
        mainAxisSpacing: AppSizes.spaceMd,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _ToolCard(item: items[i]),
    );
  }

  static final _aiTools = [
    _ToolItem(icon: Icons.auto_stories_rounded, color: const Color(0xFF6366F1), label: 'AI 학습 계획', subtitle: '시험까지 일정 자동 생성', route: '/ai-tools/study-plan'),
    _ToolItem(icon: Icons.psychology_rounded, color: const Color(0xFFEC4899), label: 'AI 오답노트', subtitle: '취약점 분석 & 개선', route: '/ai-tools/wrong-answers'),
    _ToolItem(icon: Icons.style_rounded, color: const Color(0xFF10B981), label: 'AI 플래시카드', subtitle: '핵심 개념 카드 생성', route: '/ai-tools/flashcards'),
    _ToolItem(icon: Icons.quiz_rounded, color: const Color(0xFFF59E0B), label: 'AI 예상문제', subtitle: '맞춤 문제 자동 출제', route: '/ai-tools/questions'),
    _ToolItem(icon: Icons.trending_up_rounded, color: const Color(0xFF3B82F6), label: '등급 시뮬레이션', subtitle: '예상 성적 분석', route: '/ai-tools/grade-sim'),
    _ToolItem(icon: Icons.record_voice_over_rounded, color: const Color(0xFF8B5CF6), label: 'AI 음성 질문', subtitle: '말로 질문하기', route: '/ai-tools/voice'),
    _ToolItem(icon: Icons.document_scanner_rounded, color: const Color(0xFF06B6D4), label: 'OCR 스캔', subtitle: '프린트 촬영 후 분석', route: '/ai-tools/ocr'),
    _ToolItem(icon: Icons.fact_check_rounded, color: const Color(0xFF7C3AED), label: 'AI 채점 & 해설', subtitle: '사진 찍으면 채점·풀이', route: '/ai-tools/grading'),
    _ToolItem(icon: Icons.spellcheck_rounded, color: const Color(0xFF0EA5E9), label: 'AI 영어 단어시험', subtitle: '4지선다 단어 퀴즈', route: '/ai-tools/vocab-test'),
    _ToolItem(icon: Icons.school_rounded, color: const Color(0xFFEF4444), label: 'AI 멘토', subtitle: '약점 집중 코칭', route: '/ai-tools/mentor'),
  ];

  static final _studyTools = [
    _ToolItem(icon: Icons.translate_rounded, color: const Color(0xFF0EA5E9), label: '영어 사전', subtitle: '단어 뜻·발음·예문', route: '/dictionary'),
    _ToolItem(icon: Icons.headphones_rounded, color: const Color(0xFF5E35B1), label: '집중 음악', subtitle: '무저작권 집중 사운드', route: '/focus-music'),
    _ToolItem(icon: Icons.timer_rounded, color: const Color(0xFF14B8A6), label: '포모도로 타이머', subtitle: 'AI 휴식 추천', route: '/ai-tools/pomodoro'),
    _ToolItem(icon: Icons.notifications_active_rounded, color: const Color(0xFFF97316), label: '망각곡선 알림', subtitle: '최적 복습 시점', route: '/ai-tools/forgetting-curve'),
    _ToolItem(icon: Icons.emoji_events_rounded, color: const Color(0xFFEAB308), label: '랭킹', subtitle: '크루·개인 랭킹', route: '/ranking'),
  ];
}

class _ToolItem {
  const _ToolItem({required this.icon, required this.color, required this.label, required this.subtitle, required this.route});
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final String route;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.item});
  final _ToolItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: item.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const Spacer(),
            Text(item.label, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(item.subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
