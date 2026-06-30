import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

class _Faq {
  const _Faq(this.q, this.a);
  final String q;
  final String a;
}

const _supportEmail = 'support@studyverse.app';

const _faqs = [
  _Faq('포인트는 어떻게 모으나요?',
      '공부 10분당 5P(집중 85점 이상), 연속 학습 매일 15P, 추천인 코드 입력 시 500P, 광고 시청 보상 등으로 모을 수 있어요.'),
  _Faq('추천인 코드는 어디서 입력하나요?',
      '마이페이지 → 내 정보 → 추천인 항목에서 입력합니다. 가입 후 24시간 이내에만 가능해요.'),
  _Faq('AI 기능이 작동하지 않아요.',
      '인터넷 연결을 확인하고, 잠시 후 다시 시도해 주세요. 계속 문제가 있으면 아래 이메일로 문의해 주세요.'),
  _Faq('공부 시간이 기록되지 않아요.',
      '공부 인증을 "종료하기"로 정상 종료해야 시간이 저장됩니다. 10분 이상 공부해야 포인트가 지급돼요.'),
  _Faq('회원 탈퇴하면 어떻게 되나요?',
      '모든 학습 데이터가 삭제되며, 같은 기기에서 30일간 재가입이 제한됩니다.'),
];

/// Customer support — FAQ + contact.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        title: Text('고객지원', style: AppTextStyles.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
        children: [
          Text('자주 묻는 질문', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSizes.spaceMd),
          ..._faqs.map((f) => Container(
                margin: const EdgeInsets.only(bottom: AppSizes.spaceSm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(f.q,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(f.a,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary, height: 1.5)),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: AppSizes.spaceXl),
          Text('1:1 문의', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSizes.spaceMd),
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('문의 이메일',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_supportEmail,
                          style: AppTextStyles.bodyLarge
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            const ClipboardData(text: _supportEmail));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('이메일 주소를 복사했습니다.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('복사'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('운영시간: 평일 10:00 ~ 18:00 (주말·공휴일 제외)\n'
                    '문의 시 가입 이메일과 발생한 화면을 함께 알려주시면 빠르게 도와드릴게요.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.space3xl),
        ],
      ),
    );
  }
}
