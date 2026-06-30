import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';
import 'package:studyverse/core/services/notification_service.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});
  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _aiService = ClaudeAiService();

  int _workMinutes = 25;
  int _breakMinutes = 5;

  Timer? _timer;
  int _secondsLeft = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedPomodoros = 0;
  String? _breakAdvice;
  bool _loadingAdvice = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // 포모도로 중 화면 꺼짐 방지
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _toggle() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      setState(() => _isRunning = true);
    }
  }

  void _tick() {
    if (_secondsLeft > 0) {
      setState(() => _secondsLeft--);
    } else {
      _timer?.cancel();
      setState(() { _isRunning = false; });
      _playEndSound();
      if (!_isBreak) {
        setState(() { _completedPomodoros++; _isBreak = true; _secondsLeft = _breakMinutes * 60; });
        _fetchBreakAdvice();
      } else {
        setState(() { _isBreak = false; _secondsLeft = _workMinutes * 60; _breakAdvice = null; });
      }
    }
  }

  void _playEndSound() {
    // 소리 + 진동 + 알림(소리 포함)
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
    NotificationService.instance.notify(
      _isBreak ? '휴식 끝! ⏰' : '집중 시간 완료! 🎉',
      _isBreak ? '다시 집중할 시간이에요.' : '잠깐 휴식하세요.',
    );
  }

  void _reset() {
    _timer?.cancel();
    setState(() { _isRunning = false; _isBreak = false; _secondsLeft = _workMinutes * 60; _breakAdvice = null; });
  }

  Future<void> _fetchBreakAdvice() async {
    setState(() => _loadingAdvice = true);
    try {
      final key = await _storage.read(key: 'claude_api_key') ?? '';
      if (key.isEmpty) return;
      final advice = await _aiService.recommendBreak(
        apiKey: key,
        studiedMinutes: _completedPomodoros * _workMinutes,
        focusScore: 80,
        isDrowsy: false,
      );
      if (mounted) setState(() => _breakAdvice = advice);
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingAdvice = false);
    }
  }

  Widget _timeSlider(
      String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(
            width: 72,
            child: Text(label, style: AppTextStyles.bodySmall)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value분',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
            width: 40,
            child: Text('$value분',
                textAlign: TextAlign.end,
                style: AppTextStyles.labelMedium
                    .copyWith(fontWeight: FontWeight.w700))),
      ],
    );
  }

  String get _timeLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress => _isBreak
      ? 1 - _secondsLeft / (_breakMinutes * 60)
      : 1 - _secondsLeft / (_workMinutes * 60);

  @override
  Widget build(BuildContext context) {
    final color = _isBreak ? const Color(0xFF10B981) : AppColors.primary;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('포모도로 타이머'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(
          children: [
            // 시간 조정 (실행 중이 아닐 때만)
            if (!_isRunning) ...[
              const SizedBox(height: AppSizes.spaceSm),
              _timeSlider('집중 시간', _workMinutes, 5, 60, (v) {
                setState(() {
                  _workMinutes = v;
                  if (!_isBreak) _secondsLeft = v * 60;
                });
              }),
              _timeSlider('휴식 시간', _breakMinutes, 1, 30, (v) {
                setState(() {
                  _breakMinutes = v;
                  if (_isBreak) _secondsLeft = v * 60;
                });
              }),
            ],
            const Spacer(),
            Text(_isBreak ? '☕ 휴식 시간' : '🎯 집중 시간', style: AppTextStyles.headlineSmall.copyWith(color: color)),
            const SizedBox(height: AppSizes.spaceLg),
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox.expand(child: CircularProgressIndicator(value: _progress, strokeWidth: 12, backgroundColor: color.withOpacity(0.1), color: color)),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_timeLabel, style: AppTextStyles.headlineLarge.copyWith(fontSize: 52, color: color, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('포모도로 $_completedPomodoros회 완료', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ]),
              ]),
            ),
            const SizedBox(height: AppSizes.space2xl),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(onPressed: _reset, icon: const Icon(Icons.replay_rounded, size: 32), color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.spaceLg),
              ElevatedButton(
                onPressed: _toggle,
                style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: const CircleBorder(), padding: const EdgeInsets.all(20)),
                child: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 36),
              ),
              const SizedBox(width: AppSizes.spaceLg),
              IconButton(
                onPressed: () {
                  _timer?.cancel();
                  setState(() { _isBreak = !_isBreak; _secondsLeft = _isBreak ? _breakMinutes * 60 : _workMinutes * 60; _isRunning = false; });
                },
                icon: const Icon(Icons.skip_next_rounded, size: 32),
                color: AppColors.textSecondary,
              ),
            ]),
            const SizedBox(height: AppSizes.spaceLg),
            if (_isBreak) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.spaceLg),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
                child: _loadingAdvice
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 12), Text('AI 휴식 추천 생성 중...')])
                    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [const Icon(Icons.tips_and_updates_rounded, color: Color(0xFF10B981), size: 20), const SizedBox(width: 8), Text('AI 휴식 추천', style: AppTextStyles.titleSmall.copyWith(color: const Color(0xFF10B981)))]),
                        const SizedBox(height: 8),
                        Text(_breakAdvice ?? '잠깐 눈을 감고 스트레칭 해보세요! 물 한 잔도 챙기세요. 🧘', style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
                      ]),
              ),
            ],
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int i = 0; i < 4; i++) Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: i < _completedPomodoros % 4 ? color : color.withOpacity(0.2)),
              ),
            ]),
            const SizedBox(height: AppSizes.spaceMd),
          ],
        ),
      ),
    );
  }
}
