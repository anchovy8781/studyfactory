import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';
import 'package:studyverse/features/auth/presentation/providers/auth_provider.dart';
import 'package:studyverse/features/auth/domain/models/auth_model.dart';
import 'login_screen.dart' show KeyboardDismissOnTap;

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nicknameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedTerms = false;
  bool _agreedPrivacy = false;

  // Track touched fields for validation UX
  final Set<String> _touched = {};

  int get _passwordStrength {
    final pw = _passwordController.text;
    if (pw.isEmpty) return 0;
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.contains(RegExp(r'[A-Z]'))) score++;
    if (pw.contains(RegExp(r'[0-9]'))) score++;
    if (pw.contains(RegExp(r'[!@#\$%^&*]'))) score++;
    return score;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nicknameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: KeyboardDismissOnTap(
          child: Column(
            children: [
              _buildTopBar(context),
              _buildStepper(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.paddingPageHorizontal,
                    0,
                    AppSizes.paddingPageHorizontal,
                    AppSizes.space2xl + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSizes.spaceXl),
                        Text(
                          '기본 정보를 입력해 주세요',
                          style: AppTextStyles.headlineSmall,
                        ).animate().fadeIn(duration: 500.ms),
                        const SizedBox(height: AppSizes.spaceXs),
                        Text(
                          'StudyVerse에 오신 것을 환영합니다!',
                          style: AppTextStyles.bodyMedium,
                        ).animate().fadeIn(duration: 500.ms, delay: 80.ms),
                        const SizedBox(height: AppSizes.space2xl),

                        // Nickname
                        _buildField(
                          label: '닉네임',
                          controller: _nicknameController,
                          focusNode: _nicknameFocus,
                          nextFocus: _emailFocus,
                          hint: '공부왕김철수',
                          prefixIcon: Icons.person_outline,
                          fieldKey: 'nickname',
                          validator: (v) {
                            if (!_touched.contains('nickname')) return null;
                            if (v == null || v.trim().isEmpty) return '닉네임을 입력해 주세요.';
                            if (v.trim().length < 2) return '닉네임은 2자 이상이어야 합니다.';
                            if (v.trim().length > 12) return '닉네임은 12자 이하여야 합니다.';
                            return null;
                          },
                        ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
                        const SizedBox(height: AppSizes.spaceLg),

                        // Email
                        _buildField(
                          label: '이메일',
                          controller: _emailController,
                          focusNode: _emailFocus,
                          nextFocus: _passwordFocus,
                          hint: 'study@example.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          fieldKey: 'email',
                          validator: (v) {
                            if (!_touched.contains('email')) return null;
                            if (v == null || v.isEmpty) return '이메일을 입력해 주세요.';
                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                              return '올바른 이메일 형식을 입력해 주세요.';
                            }
                            return null;
                          },
                        ).animate().fadeIn(duration: 500.ms, delay: 220.ms),
                        const SizedBox(height: AppSizes.spaceLg),

                        // Password
                        _buildField(
                          label: '비밀번호',
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          nextFocus: _confirmFocus,
                          hint: '영문, 숫자, 특수문자 포함 8자 이상',
                          prefixIcon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          fieldKey: 'password',
                          onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            if (!_touched.contains('password')) return null;
                            if (v == null || v.isEmpty) return '비밀번호를 입력해 주세요.';
                            if (v.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
                            return null;
                          },
                        ).animate().fadeIn(duration: 500.ms, delay: 290.ms),

                        // Password strength
                        if (_touched.contains('password') && _passwordController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSizes.spaceSm),
                            child: _buildPasswordStrength(),
                          ).animate().fadeIn(duration: 300.ms),
                        const SizedBox(height: AppSizes.spaceLg),

                        // Confirm password
                        _buildField(
                          label: '비밀번호 확인',
                          controller: _confirmController,
                          focusNode: _confirmFocus,
                          hint: '비밀번호를 다시 입력하세요',
                          prefixIcon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          fieldKey: 'confirm',
                          onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            if (!_touched.contains('confirm')) return null;
                            if (v == null || v.isEmpty) return '비밀번호 확인을 입력해 주세요.';
                            if (v != _passwordController.text) return '비밀번호가 일치하지 않습니다.';
                            return null;
                          },
                        ).animate().fadeIn(duration: 500.ms, delay: 360.ms),
                        const SizedBox(height: AppSizes.space2xl),

                        // Terms & Privacy
                        _buildCheckboxes()
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 420.ms),
                        const SizedBox(height: AppSizes.space2xl),

                        // Submit button
                        AppButton(
                          label: '가입하기',
                          isLoading: isLoading,
                          onPressed: isLoading || !_agreedTerms || !_agreedPrivacy ? null : _submit,
                          size: AppButtonSize.large,
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 480.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: AppSizes.spaceLg),
                        _buildLoginLink(context)
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 530.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceSm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              '회원가입',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingPageHorizontal,
        vertical: AppSizes.spaceSm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStep(1, '기본 정보', isActive: true, isDone: false),
              _buildStepLine(isActive: false),
              _buildStep(2, '프로필 설정', isActive: false, isDone: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String label, {required bool isActive, required bool isDone}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : (isDone ? AppColors.success : AppColors.border),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '$number',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceXs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: AppSizes.space2xl),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String hint,
    required IconData prefixIcon,
    required String fieldKey,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSizes.spaceSm),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscure,
          onChanged: (v) {
            setState(() => _touched.add(fieldKey));
            onChanged?.call(v);
          },
          onFieldSubmitted: (_) {
            setState(() => _touched.add(fieldKey));
            nextFocus?.requestFocus();
          },
          style: AppTextStyles.bodyLarge,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
            prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: AppSizes.iconLg),
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconLg,
                    ),
                    onPressed: onToggleObscure,
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
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrength() {
    const labels = ['약함', '보통', '강함', '매우 강함'];
    final colors = [AppColors.error, AppColors.warning, AppColors.info, AppColors.success];
    final strength = _passwordStrength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < strength ? colors[strength - 1] : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSizes.spaceXs),
        Text(
          strength > 0 ? '비밀번호 강도: ${labels[strength - 1]}' : '',
          style: AppTextStyles.caption.copyWith(
            color: strength > 0 ? colors[strength - 1] : AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxes() {
    return Column(
      children: [
        _buildCheckbox(
          value: _agreedTerms,
          label: '이용약관에 동의합니다 (필수)',
          linkText: '이용약관 보기',
          onChanged: (v) => setState(() => _agreedTerms = v ?? false),
          onTapLink: () => context.push('/terms'),
        ),
        const SizedBox(height: AppSizes.spaceSm),
        _buildCheckbox(
          value: _agreedPrivacy,
          label: '개인정보처리방침에 동의합니다 (필수)',
          linkText: '약관 보기',
          onChanged: (v) => setState(() => _agreedPrivacy = v ?? false),
          onTapLink: () => context.push('/privacy'),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required String label,
    required String linkText,
    required ValueChanged<bool?> onChanged,
    VoidCallback? onTapLink,
  }) {
    return Row(
      children: [
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: AppSizes.spaceXs),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
                const TextSpan(text: '  '),
                TextSpan(
                  text: linkText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = onTapLink ?? () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('이미 계정이 있으신가요?', style: AppTextStyles.bodyMedium),
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm),
          ),
          child: Text(
            '로그인',
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
      _touched.addAll(['nickname', 'email', 'password', 'confirm']);
    });

    if (!_agreedTerms || !_agreedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이용약관과 개인정보처리방침에 동의해 주세요.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          margin: const EdgeInsets.all(AppSizes.spaceLg),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            _nicknameController.text.trim(),
          );
    }
  }
}
