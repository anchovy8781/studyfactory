import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/shared/widgets/app_logo.dart';

// ── Session model ─────────────────────────────────────────────────────────

class _SessionEntry {
  const _SessionEntry({required this.label, required this.duration, required this.type});
  final String label;
  final Duration duration;
  final _SessionType type;
}

enum _SessionType { study, shortBreak, longBreak }

// ── Timer state ───────────────────────────────────────────────────────────

class _TimerState {
  const _TimerState({
    required this.elapsed,
    required this.isRunning,
    required this.sessions,
    required this.currentRound,
    required this.mode,
  });

  final Duration elapsed;
  final bool isRunning;
  final List<_SessionEntry> sessions;
  final int currentRound;
  final _SessionType mode;

  Duration get target => switch (mode) {
        _SessionType.study => const Duration(minutes: 25),
        _SessionType.shortBreak => const Duration(minutes: 5),
        _SessionType.longBreak => const Duration(minutes: 15),
      };

  double get progress {
    final total = target.inSeconds;
    if (total == 0) return 0;
    return (elapsed.inSeconds / total).clamp(0.0, 1.0);
  }

  _TimerState copyWith({
    Duration? elapsed,
    bool? isRunning,
    List<_SessionEntry>? sessions,
    int? currentRound,
    _SessionType? mode,
  }) =>
      _TimerState(
        elapsed: elapsed ?? this.elapsed,
        isRunning: isRunning ?? this.isRunning,
        sessions: sessions ?? this.sessions,
        currentRound: currentRound ?? this.currentRound,
        mode: mode ?? this.mode,
      );
}

class _TimerNotifier extends StateNotifier<_TimerState> {
  _TimerNotifier()
      : super(const _TimerState(
          elapsed: Duration.zero,
          isRunning: false,
          sessions: [],
          currentRound: 1,
          mode: _SessionType.study,
        ));

  Timer? _timer;

  void toggle() {
    if (state.isRunning) {
      _pause();
    } else {
      _resume();
    }
  }

  void _resume() {
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.elapsed + const Duration(seconds: 1);
      if (next >= state.target) {
        _completeSession();
      } else {
        state = state.copyWith(elapsed: next);
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void _completeSession() {
    _timer?.cancel();
    final entry = _SessionEntry(
      label: switch (state.mode) {
        _SessionType.study => '${state.currentRound}번째 집중 세션',
        _SessionType.shortBreak => '짧은 휴식',
        _SessionType.longBreak => '긴 휴식',
      },
      duration: state.elapsed,
      type: state.mode,
    );

    final nextMode = switch (state.mode) {
      _SessionType.study =>
        state.currentRound % 4 == 0 ? _SessionType.longBreak : _SessionType.shortBreak,
      _SessionType.shortBreak || _SessionType.longBreak => _SessionType.study,
    };

    final nextRound =
        state.mode == _SessionType.study ? state.currentRound + 1 : state.currentRound;

    state = state.copyWith(
      elapsed: Duration.zero,
      isRunning: false,
      sessions: [entry, ...state.sessions],
      currentRound: nextRound,
      mode: nextMode,
    );
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(elapsed: Duration.zero, isRunning: false);
  }

  void skip() {
    _timer?.cancel();
    _completeSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final _timerProvider =
    StateNotifierProvider.autoDispose<_TimerNotifier, _TimerState>(
  (ref) => _TimerNotifier(),
);

// ── Screen ────────────────────────────────────────────────────────────────

class StudyTimerScreen extends ConsumerWidget {
  const StudyTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_timerProvider);

    return Scaffold(
      backgroundColor: AppColors.timerBackground,
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
              const SizedBox(height: AppSizes.spaceXl),
              _buildModeSelector(state, ref),
              const SizedBox(height: AppSizes.space2xl),
              _buildTimerDisplay(state),
              const SizedBox(height: AppSizes.space3xl),
              _buildControls(state, ref),
              const SizedBox(height: AppSizes.space2xl),
              _buildRoundIndicator(state),
              if (state.sessions.isNotEmpty) ...[
                const SizedBox(height: AppSizes.space2xl),
                _buildSessionHistory(state),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, _TimerState state, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceLg),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
            onPressed: () {
              ref.read(_timerProvider.notifier).reset();
              context.pop();
            },
          ),
          const Spacer(),
          Text(
            '순공 타이머',
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => ref.read(_timerProvider.notifier).reset(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(_TimerState state, WidgetRef ref) {
    const modes = [
      (label: '집중', mode: _SessionType.study),
      (label: '짧은 휴식', mode: _SessionType.shortBreak),
      (label: '긴 휴식', mode: _SessionType.longBreak),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: modes.map((item) {
          final isSelected = state.mode == item.mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                // Only switch if not running
                if (!state.isRunning) {
                  ref.read(_timerProvider.notifier)
                    ..reset();
                  // Rebuild with mode change via skip pattern
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceMd),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimerDisplay(_TimerState state) {
    final remaining = state.target - state.elapsed;
    final m = remaining.inMinutes.remainder(60);
    final s = remaining.inSeconds.remainder(60);
    final timeStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Column(
      children: [
        // Circular progress
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: AppSizes.timerCircleSize,
              height: AppSizes.timerCircleSize,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: state.progress),
                duration: const Duration(milliseconds: 300),
                builder: (_, v, __) => CircularProgressIndicator(
                  value: v,
                  strokeWidth: AppSizes.timerStrokeWidth,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    switch (state.mode) {
                      _SessionType.study => AppColors.timerText,
                      _SessionType.shortBreak => AppColors.success,
                      _SessionType.longBreak => AppColors.accent,
                    },
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand mark (in center)
                const AppLogo(size: 70),
                const SizedBox(height: AppSizes.spaceSm),
                Text(
                  timeStr,
                  style: AppTextStyles.timerDisplay.copyWith(
                    fontSize: 52,
                    shadows: [
                      Shadow(
                        color: AppColors.timerText.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ).animate(target: state.isRunning ? 1 : 0).shimmer(
                      duration: 2000.ms,
                      color: AppColors.timerText.withOpacity(0.3),
                    ),
                const SizedBox(height: AppSizes.spaceXs),
                Text(
                  switch (state.mode) {
                    _SessionType.study => '집중 시간',
                    _SessionType.shortBreak => '짧은 휴식',
                    _SessionType.longBreak => '긴 휴식',
                  },
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(_TimerState state, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip button
        _CircleButton(
          icon: Icons.skip_next_rounded,
          color: Colors.white24,
          iconColor: Colors.white54,
          size: 52,
          onTap: () => ref.read(_timerProvider.notifier).skip(),
        ),
        const SizedBox(width: AppSizes.spaceXl),

        // Play/Pause
        _CircleButton(
          icon: state.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: AppColors.primary,
          iconColor: Colors.white,
          size: 76,
          onTap: () => ref.read(_timerProvider.notifier).toggle(),
          hasShadow: true,
        ),
        const SizedBox(width: AppSizes.spaceXl),

        // Reset
        _CircleButton(
          icon: Icons.replay_rounded,
          color: Colors.white24,
          iconColor: Colors.white54,
          size: 52,
          onTap: () => ref.read(_timerProvider.notifier).reset(),
        ),
      ],
    );
  }

  Widget _buildRoundIndicator(_TimerState state) {
    return Column(
      children: [
        Text(
          '${state.currentRound}번째 세션',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: AppSizes.spaceSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final isCompleted = i < (state.currentRound - 1) % 4;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCompleted ? 24 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
              ),
            );
          }),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSessionHistory(_TimerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '세션 기록',
          style: AppTextStyles.titleSmall.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AppSizes.spaceMd),
        ...state.sessions.take(5).map(
              (s) => _SessionRow(session: s),
            ),
        if (state.sessions.length > 5) ...[
          const SizedBox(height: AppSizes.spaceSm),
          Center(
            child: Text(
              '외 ${state.sessions.length - 5}개 세션',
              style: AppTextStyles.caption.copyWith(color: Colors.white38),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _CircleButton extends StatefulWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.size,
    required this.onTap,
    this.hasShadow = false,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final VoidCallback onTap;
  final bool hasShadow;

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: widget.hasShadow
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: widget.size * 0.45,
          ),
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final _SessionEntry session;

  @override
  Widget build(BuildContext context) {
    final color = switch (session.type) {
      _SessionType.study => AppColors.timerText,
      _SessionType.shortBreak => AppColors.success,
      _SessionType.longBreak => AppColors.accent,
    };

    final m = session.duration.inMinutes;
    final s = session.duration.inSeconds.remainder(60);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceSm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: AppSizes.spaceMd),
          Text(session.label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
          const Spacer(),
          Text(
            '${m}분 ${s}초',
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
