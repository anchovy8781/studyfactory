import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';
import 'package:studyverse/features/auth/presentation/providers/auth_provider.dart';
import 'login_screen.dart' show KeyboardDismissOnTap;

/// Password reset via Firebase — sends a real reset email to the address.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = '올바른 이메일을 입력해 주세요.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).sendPasswordResetEmail(email);
      setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('비밀번호 찾기'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: KeyboardDismissOnTap(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
            child: _sent ? _buildSentView() : _buildFormView(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.spaceLg),
        const Icon(Icons.lock_reset_rounded,
            size: AppSizes.icon5xl, color: AppColors.primary),
        const SizedBox(height: AppSizes.spaceLg),
        Text('가입한 이메일을 입력하세요',
            style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: AppSizes.spaceXs),
        Text(
          '입력하신 이메일로 비밀번호 재설정 링크를 보내드립니다.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.space2xl),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'study@example.com',
            hintStyle:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.email_outlined,
                color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceLg,
              vertical: AppSizes.spaceLg,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: AppSizes.borderWidthMd),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSizes.spaceMd),
          Text(
            _error!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSizes.space2xl),
        AppButton(
          label: '재설정 이메일 보내기',
          isLoading: _loading,
          onPressed: _loading ? null : _sendResetEmail,
          size: AppButtonSize.large,
        ),
      ],
    );
  }

  Widget _buildSentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.space4xl),
        const Icon(Icons.mark_email_read_rounded,
            size: AppSizes.icon5xl, color: AppColors.success),
        const SizedBox(height: AppSizes.spaceLg),
        Text('이메일을 확인해 주세요',
            style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: AppSizes.spaceSm),
        Text(
          '${_emailController.text.trim()} 으로\n비밀번호 재설정 링크를 보냈습니다.\n메일의 링크를 눌러 새 비밀번호를 설정하세요.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.space3xl),
        AppButton(
          label: '로그인으로 돌아가기',
          onPressed: () => context.pop(),
          size: AppButtonSize.large,
        ),
      ],
    );
  }
}
