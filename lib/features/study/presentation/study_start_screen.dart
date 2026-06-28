import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';
import 'package:studyverse/shared/widgets/study_character.dart';

// ── Subject data ──────────────────────────────────────────────────────────

class _Subject {
  const _Subject({required this.label, required this.emoji, required this.color});
  final String label;
  final String emoji;
  final Color color;
}

const _subjects = [
  _Subject(label: '수학', emoji: '📐', color: AppColors.subjectMath),
  _Subject(label: '영어', emoji: '🔤', color: AppColors.subjectEnglish),
  _Subject(label: '국어', emoji: '📖', color: Color(0xFF8D6E63)),
  _Subject(label: '과학', emoji: '🔬', color: AppColors.subjectScience),
  _Subject(label: '사회', emoji: '🌍', color: Color(0xFF5C6BC0)),
  _Subject(label: '기타', emoji: '✏️', color: AppColors.textSecondary),
];

// ── AI Mode options ───────────────────────────────────────────────────────

class _AiMode {
  const _AiMode({required this.title, required this.description, required this.icon});
  final String title;
  final String description;
  final IconData icon;
}

const _aiModes = [
  _AiMode(
    title: 'AI 실시간 인증',
    description: '카메라로 AI가 공부를 인증합니다',
    icon: Icons.verified_user_rounded,
  ),
  _AiMode(
    title: '방해 요소 감지',
    description: '휴대폰, 졸음 감지',
    icon: Icons.phonelink_off_rounded,
  ),
  _AiMode(
    title: '집중도 분석',
    description: '실시간 집중도 점수',
    icon: Icons.psychology_rounded,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────

class StudyStartScreen extends ConsumerStatefulWidget {
  const StudyStartScreen({super.key});

  @override
  ConsumerState<StudyStartScreen> createState() => _StudyStartScreenState();
}

class _StudyStartScreenState extends ConsumerState<StudyStartScreen> {
  int _selectedSubject = 0;
  final Set<int> _selectedModes = {0, 1, 2};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingPageHorizontal,
          AppSizes.spaceLg,
          AppSizes.paddingPageHorizontal,
          AppSizes.space2xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCharacterSection(),
            const SizedBox(height: AppSizes.space2xl),
            _buildSubjectSection(),
            const SizedBox(height: AppSizes.space2xl),
            _buildAiModeSection(),
            const SizedBox(height: AppSizes.space3xl),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text('공부 시작', style: AppTextStyles.titleLarge),
      centerTitle: true,
    );
  }

  Widget _buildCharacterSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingCardLg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '공부할 준비가\n되셨나요?',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceSm),
                Text(
                  '오늘도 최선을 다해봐요! 💪',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          StudyCharacter(
            size: AppSizes.characterSm + 20,
            mood: CharacterMood.cheering,
          ).animate().fadeIn(duration: 500.ms).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                curve: Curves.elasticOut,
              ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.05, end: 0);
  }

  Widget _buildSubjectSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '공부할 과목을 선택하세요',
          style: AppTextStyles.titleMedium,
        ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
        const SizedBox(height: AppSizes.spaceMd),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSizes.spaceMd,
            crossAxisSpacing: AppSizes.spaceMd,
            childAspectRatio: 1.4,
          ),
          itemCount: _subjects.length,
          itemBuilder: (context, i) => _buildSubjectChip(i),
        ).animate().fadeIn(duration: 500.ms, delay: 180.ms),
      ],
    );
  }

  Widget _buildSubjectChip(int index) {
    final subject = _subjects[index];
    final isSelected = _selectedSubject == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedSubject = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? subject.color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isSelected ? subject.color : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: subject.color.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(subject.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: AppSizes.spaceXs),
            Text(
              subject.label,
              style: AppTextStyles.titleSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology_rounded, color: AppColors.primary, size: AppSizes.iconLg),
            const SizedBox(width: AppSizes.spaceSm),
            Text('공부 인증 모드', style: AppTextStyles.titleMedium),
          ],
        ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
        const SizedBox(height: AppSizes.spaceMd),
        ...List.generate(
          _aiModes.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spaceSm),
            child: _buildAiModeCard(i),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 300 + i * 60)),
        ),
      ],
    );
  }

  Widget _buildAiModeCard(int index) {
    final mode = _aiModes[index];
    final isSelected = _selectedModes.contains(index);

    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected && _selectedModes.length > 1) {
          _selectedModes.remove(index);
        } else {
          _selectedModes.add(index);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSizes.paddingCard),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? AppSizes.borderWidthMd : AppSizes.borderWidth,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                mode.icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: AppSizes.iconLg,
              ),
            ),
            const SizedBox(width: AppSizes.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode.title, style: AppTextStyles.titleSmall),
                  Text(mode.description, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final subject = _subjects[_selectedSubject];

    return Column(
      children: [
        AppButton(
          label: '${subject.emoji} 공부 시작',
          onPressed: () => context.go('/study/certification'),
          size: AppButtonSize.large,
        ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: AppSizes.spaceMd),
        TextButton.icon(
          onPressed: () => context.go('/study/timer'),
          icon: const Icon(Icons.timer_rounded, color: AppColors.textSecondary, size: AppSizes.iconMd),
          label: Text(
            '타이머만 사용하기',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 560.ms),
      ],
    );
  }
}
