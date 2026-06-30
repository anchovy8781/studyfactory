import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';

const onboardingDoneKey = 'onboarding_done';

class _Question {
  const _Question(this.question, this.options);
  final String question;
  final List<String> options;
}

const _questions = [
  _Question('하루 평균 공부 시간은 어느 정도인가요?',
      ['1시간 미만', '1~3시간', '3~5시간', '5시간 이상']),
  _Question('주로 언제 공부하나요?', ['아침', '오후', '저녁', '새벽']),
  _Question('가장 집중이 잘 되는 환경은?', ['조용한 방', '카페', '도서관/독서실', '음악과 함께']),
  _Question('공부할 때 가장 어려운 점은?', ['집중력 유지', '계획 세우기', '암기', '꾸준함']),
  _Question('주요 학습 목표는?', ['자격증', '수능/내신', '어학(토익 등)', '기타']),
];

/// One-time onboarding: 5 questions about the user's study habits.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _answers = <int, String>{};
  int _page = 0;
  bool _saving = false;

  Future<void> _finish() async {
    setState(() => _saving = true);
    // Save profile to Firestore (best-effort) + mark done locally.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final profile = <String, String>{};
    for (var i = 0; i < _questions.length; i++) {
      profile['q${i + 1}_${_questions[i].question}'] = _answers[i] ?? '';
    }
    try {
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'studyProfile': profile}, SetOptions(merge: true));
      }
    } catch (_) {/* ignore */}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingDoneKey, true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_page];
    final selected = _answers[_page];
    final isLast = _page == _questions.length - 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.spaceLg),
              // Progress
              Row(
                children: List.generate(_questions.length, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                          right: i < _questions.length - 1 ? 6 : 0),
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= _page
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSizes.space2xl),
              Text('${_page + 1} / ${_questions.length}',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary)),
              const SizedBox(height: AppSizes.spaceSm),
              Text(q.question, style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppSizes.space2xl),
              ...q.options.map((opt) {
                final sel = opt == selected;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spaceMd),
                  child: GestureDetector(
                    onTap: () => setState(() => _answers[_page] = opt),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.spaceLg),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primaryContainer
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        border: Border.all(
                          color: sel ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            sel
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: sel
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: AppSizes.spaceMd),
                          Text(opt,
                              style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight:
                                      sel ? FontWeight.w700 : FontWeight.w500,
                                  color: sel
                                      ? AppColors.primary
                                      : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              AppButton(
                label: isLast ? '시작하기' : '다음',
                isLoading: _saving,
                onPressed: selected == null || _saving
                    ? null
                    : () {
                        if (isLast) {
                          _finish();
                        } else {
                          setState(() => _page++);
                        }
                      },
                size: AppButtonSize.large,
              ),
              const SizedBox(height: AppSizes.spaceSm),
              if (_page == 0)
                TextButton(
                  onPressed: _saving ? null : _finish,
                  child: Text('건너뛰기',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ),
              const SizedBox(height: AppSizes.spaceSm),
            ],
          ),
        ),
      ),
    );
  }
}
