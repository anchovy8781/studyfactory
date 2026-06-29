import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';
import 'package:studyverse/features/auth/presentation/providers/auth_provider.dart';
import 'login_screen.dart' show KeyboardDismissOnTap;

/// Working password-reset flow (fully local).
///
/// Step 1: enter the registered email → verified against local accounts.
/// Step 2: set a new password → persisted so the user can log in immediately.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  int _step = 0; // 0 = verify email, 1 = set new password
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .requestPasswordReset(_emailController.text.trim());
      setState(() => _step = 1);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final pw = _passwordController.text;
    if (pw.length < 8) {
      setState(() => _error = '비밀번호는 8자 이상이어야 합니다.');
      return;
    }
    if (pw != _confirmController.text) {
      setState(() => _error = '비밀번호가 일치하지 않습니다.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .resetPassword(_emailController.text.trim(), pw);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('비밀번호가 변경되었습니다. 새 비밀번호로 로그인해 주세요.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          margin: const EdgeInsets.all(AppSizes.spaceLg),
        ),
      );
      context.pop();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.spaceLg),
                Icon(
                  _step == 0 ? Icons.lock_reset_rounded : Icons.password_rounded,
                  size: AppSizes.icon5xl,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.spaceLg),
                Text(
                  _step == 0 ? '가입한 이메일을 입력하세요' : '새 비밀번호를 설정하세요',
                  style: AppTextStyles.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceXs),
                Text(
                  _step == 0
                      ? '계정 확인 후 비밀번호를 재설정할 수 있습니다.'
                      : '${_emailController.text.trim()} 계정의 새 비밀번호입니다.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.space2xl),

                if (_step == 0)
                  _field(
                    controller: _emailController,
                    hint: 'study@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  )
                else ...[
                  _field(
                    controller: _passwordController,
                    hint: '새 비밀번호 (8자 이상)',
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    onToggle: () => setState(() => _obscure = !_obscure),
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  _field(
                    controller: _confirmController,
                    hint: '새 비밀번호 확인',
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                  ),
                ],

                if (_error != null) ...[
                  const SizedBox(height: AppSizes.spaceMd),
                  Text(
                    _error!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: AppSizes.space2xl),
                AppButton(
                  label: _step == 0 ? '다음' : '비밀번호 변경',
                  isLoading: _loading,
                  onPressed: _loading
                      ? null
                      : (_step == 0 ? _verifyEmail : _resetPassword),
                  size: AppButtonSize.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: onToggle != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: onToggle,
              )
            : null,
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
    );
  }
}
