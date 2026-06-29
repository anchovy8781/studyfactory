import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';

import 'package:studyverse/shared/widgets/study_character.dart';
import 'package:studyverse/features/auth/presentation/providers/auth_provider.dart';
import 'package:studyverse/features/auth/domain/models/auth_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      next.whenOrNull(
        authenticated: (_) => context.go('/home'),
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              margin: const EdgeInsets.all(AppSizes.spaceLg),
            ),
          );
          ref.read(authProvider.notifier).clearError();
        },
      );
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: KeyboardDismissOnTap(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildCard(isLoading)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingPageHorizontal,
        vertical: AppSizes.space3xl,
      ),
      child: Column(
        children: [
          Animate(
            effects: const [
              FadeEffect(duration: Duration(milliseconds: 600)),
              SlideEffect(
                begin: Offset(0, -0.2),
                end: Offset.zero,
                curve: Curves.easeOut,
              ),
            ],
            child: StudyCharacter(
              size: AppSizes.characterMd,
              mood: CharacterMood.happy,
            ),
          ),
          const SizedBox(height: AppSizes.spaceLg),
          Animate(
            effects: const [
              FadeEffect(
                duration: Duration(milliseconds: 600),
                delay: Duration(milliseconds: 150),
              ),
            ],
            child: Text(
              'StudyVerse',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceXs),
          Animate(
            effects: const [
              FadeEffect(
                duration: Duration(milliseconds: 600),
                delay: Duration(milliseconds: 250),
              ),
            ],
            child: Text(
              'AI 공부 인증 & 리워드 플랫폼',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(bool isLoading) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXxl),
          topRight: Radius.circular(AppSizes.radiusXxl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingPageHorizontal,
        AppSizes.space2xl,
        AppSizes.paddingPageHorizontal,
        AppSizes.space2xl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '로그인',
              style: AppTextStyles.headlineSmall,
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms),
            const SizedBox(height: AppSizes.spaceXs),
            Text(
              '계정에 로그인하여 공부를 시작하세요',
              style: AppTextStyles.bodyMedium,
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 350.ms),
            const SizedBox(height: AppSizes.space2xl),

            // Email field
            _buildEmailField()
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms)
                .slideX(begin: -0.05, end: 0),

            const SizedBox(height: AppSizes.spaceLg),

            // Password field
            _buildPasswordField()
                .animate()
                .fadeIn(duration: 500.ms, delay: 470.ms)
                .slideX(begin: -0.05, end: 0),

            const SizedBox(height: AppSizes.spaceSm),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceSm,
                    vertical: AppSizes.spaceXs,
                  ),
                ),
                child: Text(
                  '비밀번호 찾기',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms),

            const SizedBox(height: AppSizes.spaceXl),

            // Login button
            AppButton(
              label: '로그인',
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
              size: AppButtonSize.large,
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 540.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: AppSizes.spaceXl),

            // Divider
            _buildDivider()
                .animate()
                .fadeIn(duration: 500.ms, delay: 580.ms),

            const SizedBox(height: AppSizes.spaceXl),

            // Social buttons
            _buildSocialButtons()
                .animate()
                .fadeIn(duration: 500.ms, delay: 620.ms),

            const SizedBox(height: AppSizes.space2xl),

            // Register link
            _buildRegisterLink()
                .animate()
                .fadeIn(duration: 500.ms, delay: 660.ms),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.15, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이메일',
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: AppSizes.spaceSm),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (!_emailTouched) setState(() => _emailTouched = true);
          },
          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          style: AppTextStyles.bodyLarge,
          decoration: _inputDecoration(
            hint: 'study@example.com',
            prefixIcon: Icons.email_outlined,
          ),
          validator: (value) {
            if (!_emailTouched) return null;
            if (value == null || value.isEmpty) return '이메일을 입력해 주세요.';
            final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) return '올바른 이메일 형식을 입력해 주세요.';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '비밀번호',
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: AppSizes.spaceSm),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (!_passwordTouched) setState(() => _passwordTouched = true);
          },
          onFieldSubmitted: (_) => _submit(),
          style: AppTextStyles.bodyLarge,
          decoration: _inputDecoration(
            hint: '비밀번호를 입력하세요',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
                size: AppSizes.iconLg,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            if (!_passwordTouched) return null;
            if (value == null || value.isEmpty) return '비밀번호를 입력해 주세요.';
            if (value.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: AppSizes.iconLg),
      suffixIcon: suffixIcon,
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
        borderSide: const BorderSide(color: AppColors.primary, width: AppSizes.borderWidthMd),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: AppSizes.borderWidthMd),
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMd),
          child: Text(
            '또는',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        Text(
          '소셜 로그인',
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: AppSizes.spaceMd),
        Row(
          children: [
            Expanded(child: _buildSocialButton(label: 'Google', provider: 'google', color: Colors.white, textColor: AppColors.textPrimary, icon: _googleIcon())),
            const SizedBox(width: AppSizes.spaceMd),
            Expanded(child: _buildSocialButton(label: 'Kakao', provider: 'kakao', color: const Color(0xFFFEE500), textColor: const Color(0xFF191919), icon: _kakaoIcon())),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required String provider,
    required Color color,
    required Color textColor,
    required Widget icon,
  }) {
    return GestureDetector(
      onTap: () => ref.read(authProvider.notifier).socialLogin(provider),
      child: Container(
        height: AppSizes.buttonHeightMd,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: AppSizes.spaceSm),
            Text(
              label,
              style: AppTextStyles.buttonSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleIcon() {
    return const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4285F4)));
  }

  Widget _kakaoIcon() {
    return const Text('K', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191919)));
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '계정이 없으신가요?',
          style: AppTextStyles.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.push('/register'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm),
          ),
          child: Text(
            '회원가입',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
    });
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }
}

/// Dismisses the keyboard when tapping outside text fields.
class KeyboardDismissOnTap extends StatelessWidget {
  const KeyboardDismissOnTap({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
