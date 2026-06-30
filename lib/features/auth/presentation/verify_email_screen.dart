import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';
import 'package:studyverse/features/auth/presentation/providers/auth_provider.dart';

/// Shown right after sign-up. Prompts the user to verify their email via the
/// link Firebase just sent, and lets them resend or re-check.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _checking = false;
  bool _resending = false;

  Future<void> _checkVerified() async {
    setState(() => _checking = true);
    final verified =
        await ref.read(authProvider.notifier).reloadAndCheckEmailVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    if (verified) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('아직 인증되지 않았습니다. 메일의 링크를 눌러주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await ref.read(authProvider.notifier).resendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증 메일을 다시 보냈습니다.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_rounded,
                  size: AppSizes.icon5xl, color: AppColors.primary),
              const SizedBox(height: AppSizes.spaceXl),
              Text('이메일 인증을 완료해주세요',
                  style: AppTextStyles.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.spaceSm),
              Text(
                '가입하신 이메일로 인증 링크를 보냈습니다.\n'
                '메일함에서 링크를 누른 뒤 아래 버튼을 눌러주세요.\n'
                '(스팸함도 확인해보세요)',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.space3xl),
              AppButton(
                label: '인증 완료했어요',
                isLoading: _checking,
                onPressed: _checking ? null : _checkVerified,
                size: AppButtonSize.large,
              ),
              const SizedBox(height: AppSizes.spaceMd),
              TextButton(
                onPressed: _resending ? null : _resend,
                child: Text(
                  _resending ? '전송 중...' : '인증 메일 다시 보내기',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  '나중에 인증하기',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
