import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_button.dart';
import 'package:studyverse/shared/widgets/study_character.dart';

// ── AI Analysis item ──────────────────────────────────────────────────────

enum _AnalysisStatus { ok, warning, error }

class _AnalysisItem {
  const _AnalysisItem({
    required this.label,
    required this.status,
    required this.detail,
  });
  final String label;
  final _AnalysisStatus status;
  final String detail;
}

// ── Riverpod state ────────────────────────────────────────────────────────

class _CertificationState {
  const _CertificationState({
    required this.elapsed,
    required this.focusScore,
    required this.items,
    required this.isPaused,
  });

  final Duration elapsed;
  final double focusScore;
  final List<_AnalysisItem> items;
  final bool isPaused;

  _CertificationState copyWith({
    Duration? elapsed,
    double? focusScore,
    List<_AnalysisItem>? items,
    bool? isPaused,
  }) =>
      _CertificationState(
        elapsed: elapsed ?? this.elapsed,
        focusScore: focusScore ?? this.focusScore,
        items: items ?? this.items,
        isPaused: isPaused ?? this.isPaused,
      );
}

class _CertificationNotifier extends StateNotifier<_CertificationState> {
  _CertificationNotifier()
      : super(
          _CertificationState(
            elapsed: Duration.zero,
            focusScore: 95.0,
            isPaused: false,
            items: _defaultItems,
          ),
        ) {
    _start();
  }

  Timer? _timer;
  int _tick = 0;

  static const _defaultItems = [
    _AnalysisItem(label: '얼굴 인식', status: _AnalysisStatus.ok, detail: '정상'),
    _AnalysisItem(label: '시선 추적', status: _AnalysisStatus.ok, detail: '정상'),
    _AnalysisItem(label: '자리 이탈', status: _AnalysisStatus.ok, detail: '없음'),
    _AnalysisItem(label: '휴대폰 사용', status: _AnalysisStatus.ok, detail: '없음'),
    _AnalysisItem(label: '졸음 감지', status: _AnalysisStatus.warning, detail: '약함 감지'),
  ];

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isPaused) return;
      _tick++;

      // Simulate dynamic AI analysis changes
      final items = List<_AnalysisItem>.from(_defaultItems);

      // Occasionally update focus score
      final scoreDelta = (_tick % 10 == 0) ? ((_tick ~/ 10).isOdd ? -2.0 : 1.5) : 0.0;
      final newScore = (state.focusScore + scoreDelta).clamp(60.0, 100.0);

      // Simulate drowsiness resolved after 30 seconds
      if (_tick > 30) {
        items[4] = const _AnalysisItem(
          label: '졸음 감지',
          status: _AnalysisStatus.ok,
          detail: '없음',
        );
      }

      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
        focusScore: newScore,
        items: items,
      );
    });
  }

  void togglePause() => state = state.copyWith(isPaused: !state.isPaused);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final _certificationProvider =
    StateNotifierProvider.autoDispose<_CertificationNotifier, _CertificationState>(
  (ref) => _CertificationNotifier(),
);

// ── Screen ────────────────────────────────────────────────────────────────

class StudyCertificationScreen extends ConsumerWidget {
  const StudyCertificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_certificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingPageHorizontal,
            0,
            AppSizes.paddingPageHorizontal,
            AppSizes.space2xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(context, state, ref),
              const SizedBox(height: AppSizes.spaceLg),
              _buildTimerSection(state),
              const SizedBox(height: AppSizes.spaceLg),
              _buildCameraPreview(),
              const SizedBox(height: AppSizes.spaceLg),
              _buildFocusScore(state),
              const SizedBox(height: AppSizes.spaceLg),
              _buildAnalysisList(state),
              const SizedBox(height: AppSizes.space2xl),
              _buildControlButtons(context, state, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, _CertificationState state, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceLg),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => _showStopDialog(context, ref),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                '공부 인증 진행 중',
                style: AppTextStyles.titleMedium,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4CAF50),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(begin: 0.3, end: 1.0, duration: 800.ms),
                  const SizedBox(width: 6),
                  Text(
                    'AI 분석 중',
                    style: AppTextStyles.caption.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => ref.read(_certificationProvider.notifier).togglePause(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection(_CertificationState state) {
    final h = state.elapsed.inHours;
    final m = state.elapsed.inMinutes.remainder(60);
    final s = state.elapsed.inSeconds.remainder(60);
    final timeStr =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.space2xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // Circular progress with character
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: AppSizes.timerCircleSize,
                height: AppSizes.timerCircleSize,
                child: CircularProgressIndicator(
                  value: (state.elapsed.inSeconds % 3600) / 3600,
                  strokeWidth: AppSizes.timerStrokeWidth,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    state.isPaused ? AppColors.textSecondary : AppColors.primary,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StudyCharacter(
                    size: AppSizes.characterSm + 10,
                    mood: state.isPaused ? CharacterMood.sleeping : CharacterMood.studying,
                    animate: !state.isPaused,
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  Text(
                    timeStr,
                    style: AppTextStyles.timerDisplay.copyWith(
                      fontSize: 42,
                      color: state.isPaused ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    state.isPaused ? '일시 정지됨' : '공부 중',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: state.isPaused ? AppColors.textSecondary : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.timerBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppColors.cardShadow,
      ),
      child: Stack(
        children: [
          // Simulated camera grid lines
          CustomPaint(
            size: const Size(double.infinity, 160),
            painter: _CameraGridPainter(),
          ),
          // Corner brackets
          ..._buildCameraCorners(),
          // Center face detection box
          Center(
            child: Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.success.withOpacity(0.8),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .custom(
                  duration: 1500.ms,
                  builder: (_, v, child) => Opacity(opacity: 0.5 + v * 0.5, child: child),
                ),
          ),
          // Camera label
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'AI 카메라 활성화됨',
                      style: AppTextStyles.caption.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  List<Widget> _buildCameraCorners() {
    const color = AppColors.primary;
    const length = 20.0;
    const strokeWidth = 3.0;

    return [
      // Top-left
      Positioned(
        top: 12,
        left: 12,
        child: _CornerBracket(color: color, length: length, strokeWidth: strokeWidth, topLeft: true),
      ),
      // Top-right
      Positioned(
        top: 12,
        right: 12,
        child: _CornerBracket(color: color, length: length, strokeWidth: strokeWidth, topRight: true),
      ),
      // Bottom-left
      Positioned(
        bottom: 12,
        left: 12,
        child: _CornerBracket(color: color, length: length, strokeWidth: strokeWidth, bottomLeft: true),
      ),
      // Bottom-right
      Positioned(
        bottom: 12,
        right: 12,
        child: _CornerBracket(color: color, length: length, strokeWidth: strokeWidth, bottomRight: true),
      ),
    ];
  }

  Widget _buildFocusScore(_CertificationState state) {
    final score = state.focusScore;
    final color = score >= 80
        ? AppColors.success
        : score >= 60
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingCardLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.track_changes_rounded, color: AppColors.primary, size: AppSizes.iconLg),
              const SizedBox(width: AppSizes.spaceSm),
              Text('실시간 집중도', style: AppTextStyles.titleSmall),
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: score),
                duration: const Duration(milliseconds: 800),
                builder: (_, v, __) => Text(
                  '${v.toStringAsFixed(0)}%',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            score >= 80
                ? '훌륭해요! 집중력이 매우 높습니다 🎉'
                : score >= 60
                    ? '집중도가 보통입니다. 조금 더 집중해보세요!'
                    : '집중도가 낮습니다. 잠시 휴식을 취해보세요.',
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisList(_CertificationState state) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingCardLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: AppColors.primary, size: AppSizes.iconLg),
              const SizedBox(width: AppSizes.spaceSm),
              Text('AI 분석 결과', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSizes.spaceSm),
          ...state.items.map((item) => _buildAnalysisRow(item)),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(_AnalysisItem item) {
    final (icon, color, bg) = switch (item.status) {
      _AnalysisStatus.ok => (Icons.check_circle_rounded, AppColors.success, AppColors.successLight),
      _AnalysisStatus.warning => (Icons.warning_rounded, AppColors.warning, AppColors.warningLight),
      _AnalysisStatus.error => (Icons.error_rounded, AppColors.error, AppColors.errorLight),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXs),
      child: Row(
        children: [
          Text(item.label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceSm, vertical: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Text(
                  item.detail,
                  style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, _CertificationState state, WidgetRef ref) {
    return Column(
      children: [
        AppButton(
          label: state.isPaused ? '공부 재개' : '일시 정지',
          variant: state.isPaused ? AppButtonVariant.primary : AppButtonVariant.outline,
          onPressed: () => ref.read(_certificationProvider.notifier).togglePause(),
          icon: state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          size: AppButtonSize.large,
        ),
        const SizedBox(height: AppSizes.spaceMd),
        AppButton(
          label: '공부 종료',
          variant: AppButtonVariant.danger,
          onPressed: () => _showStopDialog(context, ref),
          icon: Icons.stop_rounded,
          size: AppButtonSize.large,
        ),
      ],
    );
  }

  void _showStopDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: const Text('공부 종료'),
        content: const Text('공부 세션을 종료하시겠습니까?\n지금까지의 기록이 저장됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('계속 공부하기'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/home');
            },
            child: const Text('종료하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Custom painters ────────────────────────────────────────────────────────

class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    final cols = 8;
    final rows = 5;

    for (int i = 1; i < cols; i++) {
      final x = size.width * i / cols;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int j = 1; j < rows; j++) {
      final y = size.height * j / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_CameraGridPainter old) => false;
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({
    required this.color,
    required this.length,
    required this.strokeWidth,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  final Color color;
  final double length;
  final double strokeWidth;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(length, length),
      painter: _CornerPainter(
        color: color,
        strokeWidth: strokeWidth,
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  final Color color;
  final double strokeWidth;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    if (topLeft) {
      canvas.drawLine(Offset(0, h), Offset(0, 0), paint);
      canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
    } else if (topRight) {
      canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
    } else if (bottomLeft) {
      canvas.drawLine(Offset(0, 0), Offset(0, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    } else if (bottomRight) {
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    }
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
