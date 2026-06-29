import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Navigate after 2.5 seconds, checking auth state
    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final authState = ref.read(authProvider);
    authState.when(
      authenticated: (_) => context.go('/home'),
      initial: () => context.go('/login'),
      loading: () => context.go('/login'),
      unauthenticated: () => context.go('/login'),
      error: (_) => context.go('/login'),
    );
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            // Background floating circles
            ..._buildBackgroundDecorations(),
            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    _buildLogo(),
                    const SizedBox(height: AppSizes.space2xl),
                    // App name
                    _buildAppName(),
                    const SizedBox(height: AppSizes.spaceLg),
                    // Tagline
                    _buildTagline(),
                    const Spacer(flex: 3),
                    // Loading indicator
                    _buildLoadingIndicator(),
                    const SizedBox(height: AppSizes.space2xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundDecorations() {
    return [
      Positioned(
        top: -60,
        right: -40,
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      Positioned(
        bottom: 80,
        left: -60,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      Positioned(
        top: 160,
        left: -30,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.04),
          ),
        ),
      ),
      Positioned(
        bottom: 200,
        right: -20,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.07),
          ),
        ),
      ),
    ];
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'S',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            height: 1,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), curve: Curves.elasticOut);
  }

  Widget _buildAppName() {
    return Text(
      'StudyVerse',
      style: AppTextStyles.headlineLarge.copyWith(
        color: Colors.white,
        fontSize: 38,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 700.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceLg,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        'AI 공부 인증 & 리워드 플랫폼',
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 900.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: AppSizes.spaceMd),
        Text(
          '로딩 중...',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1200.ms);
  }
}
