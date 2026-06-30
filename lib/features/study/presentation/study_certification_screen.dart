import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:studyverse/core/services/face_detection_service.dart';
import 'package:studyverse/core/services/rewards_service.dart';
import 'package:studyverse/core/services/notification_service.dart';
import 'package:studyverse/shared/widgets/app_button.dart';
import 'package:studyverse/shared/widgets/app_logo.dart';

// ── Analysis state model ──────────────────────────────────────────────────────

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

// ── Riverpod state ────────────────────────────────────────────────────────────

class _CertificationState {
  const _CertificationState({
    required this.elapsed,
    required this.focusScore,
    required this.items,
    required this.isPaused,
    this.faceResult,
    this.lastScanAt,
  });

  final Duration elapsed;
  final double focusScore;
  final List<_AnalysisItem> items;
  final bool isPaused;
  final FaceDetectionResult? faceResult;
  final DateTime? lastScanAt;

  _CertificationState copyWith({
    Duration? elapsed,
    double? focusScore,
    List<_AnalysisItem>? items,
    bool? isPaused,
    FaceDetectionResult? faceResult,
    DateTime? lastScanAt,
  }) =>
      _CertificationState(
        elapsed: elapsed ?? this.elapsed,
        focusScore: focusScore ?? this.focusScore,
        items: items ?? this.items,
        isPaused: isPaused ?? this.isPaused,
        faceResult: faceResult ?? this.faceResult,
        lastScanAt: lastScanAt ?? this.lastScanAt,
      );
}

class _CertificationNotifier extends StateNotifier<_CertificationState> {
  _CertificationNotifier()
      : super(
          _CertificationState(
            elapsed: Duration.zero,
            focusScore: 95.0,
            isPaused: false,
            items: _waitingItems,
          ),
        ) {
    _startTimer();
  }

  Timer? _timer;

  static const _waitingItems = [
    _AnalysisItem(label: '얼굴 인식', status: _AnalysisStatus.warning, detail: '대기 중'),
    _AnalysisItem(label: '시선 추적', status: _AnalysisStatus.warning, detail: '대기 중'),
    _AnalysisItem(label: '자리 이탈', status: _AnalysisStatus.ok, detail: '없음'),
    _AnalysisItem(label: '휴대폰 사용', status: _AnalysisStatus.ok, detail: '없음'),
    _AnalysisItem(label: '졸음 감지', status: _AnalysisStatus.ok, detail: '없음'),
  ];

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isPaused) return;
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }

  void togglePause() => state = state.copyWith(isPaused: !state.isPaused);

  void updateFromFaceResult(FaceDetectionResult result) {
    final newItems = _itemsFromResult(result);
    // Weighted blend: 30% old score, 70% new face score
    final blended =
        (state.focusScore * 0.3 + result.focusScore * 0.7).clamp(0.0, 100.0);

    state = state.copyWith(
      faceResult: result,
      lastScanAt: DateTime.now(),
      items: newItems,
      focusScore: blended,
    );
  }

  static List<_AnalysisItem> _itemsFromResult(FaceDetectionResult result) {
    if (!result.faceDetected) {
      return const [
        _AnalysisItem(label: '얼굴 인식', status: _AnalysisStatus.error, detail: '감지 안됨'),
        _AnalysisItem(label: '시선 추적', status: _AnalysisStatus.error, detail: '불가'),
        _AnalysisItem(label: '자리 이탈', status: _AnalysisStatus.warning, detail: '확인 필요'),
        _AnalysisItem(label: '휴대폰 사용', status: _AnalysisStatus.ok, detail: '없음'),
        _AnalysisItem(label: '졸음 감지', status: _AnalysisStatus.ok, detail: '없음'),
      ];
    }
    return [
      const _AnalysisItem(label: '얼굴 인식', status: _AnalysisStatus.ok, detail: '정상'),
      _AnalysisItem(
        label: '시선 추적',
        status: result.lookingAtCamera == true
            ? _AnalysisStatus.ok
            : _AnalysisStatus.warning,
        detail: result.lookingAtCamera == true ? '화면 응시' : '시선 이탈',
      ),
      const _AnalysisItem(label: '자리 이탈', status: _AnalysisStatus.ok, detail: '없음'),
      const _AnalysisItem(label: '휴대폰 사용', status: _AnalysisStatus.ok, detail: '없음'),
      _AnalysisItem(
        label: '졸음 감지',
        status: result.drowsy == true ? _AnalysisStatus.warning : _AnalysisStatus.ok,
        detail: result.drowsy == true ? '졸음 감지' : '없음',
      ),
    ];
  }

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

// ── Screen ────────────────────────────────────────────────────────────────────

class StudyCertificationScreen extends ConsumerStatefulWidget {
  const StudyCertificationScreen({super.key, this.subject = ''});

  /// Subject the user chose on the start screen (for the study log).
  final String subject;

  @override
  ConsumerState<StudyCertificationScreen> createState() =>
      _StudyCertificationScreenState();
}

class _StudyCertificationScreenState
    extends ConsumerState<StudyCertificationScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _cameraReady = false;
  bool _permissionDenied = false;
  bool _isScanning = false;
  Timer? _autoScanTimer;
  final FaceDetectionService _faceService = FaceDetectionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable(); // AI 공부 중 화면 꺼짐 방지
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _autoScanTimer?.cancel();
      ctrl.dispose();
      if (mounted) setState(() { _controller = null; _cameraReady = false; });
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _permissionDenied = true);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await ctrl.initialize();
      if (!mounted) { ctrl.dispose(); return; }

      setState(() {
        _controller = ctrl;
        _cameraReady = true;
      });

      // Initial scan after 2 seconds
      Future.delayed(const Duration(seconds: 2), _doScan);
      // Auto-scan every 5 seconds (AI 카메라 자동 분석)
      _autoScanTimer = Timer.periodic(const Duration(seconds: 5), (_) => _doScan());
    } catch (e) {
      debugPrint('[Camera] init error: $e');
    }
  }

  Future<void> _doScan() async {
    if (_isScanning || !_cameraReady || _controller == null) return;
    if (ref.read(_certificationProvider).isPaused) return;

    setState(() => _isScanning = true);
    try {
      final xFile = await _controller!.takePicture();
      final result = await _faceService.analyzeFromFile(xFile.path);
      if (result != null && mounted) {
        ref.read(_certificationProvider.notifier).updateFromFaceResult(result);
      }
    } catch (e) {
      debugPrint('[Scan] $e');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _autoScanTimer?.cancel();
    _controller?.dispose();
    _faceService.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
              _buildTopBar(context, state),
              const SizedBox(height: AppSizes.spaceLg),
              _buildTimerSection(state),
              const SizedBox(height: AppSizes.spaceLg),
              _buildCameraSection(state),
              const SizedBox(height: AppSizes.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('인식된 영상은 서버에 저장되지 않습니다',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: AppSizes.spaceLg),
              _buildFocusScore(state),
              const SizedBox(height: AppSizes.spaceLg),
              _buildAnalysisList(state),
              const SizedBox(height: AppSizes.space2xl),
              _buildControlButtons(context, state),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, _CertificationState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceLg),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary),
            onPressed: () => _showStopDialog(context),
          ),
          const Spacer(),
          Column(
            children: [
              Text('공부 인증 진행 중', style: AppTextStyles.titleMedium),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _cameraReady ? AppColors.success : AppColors.warning,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(begin: 0.3, end: 1.0, duration: 800.ms),
                  const SizedBox(width: 6),
                  Text(
                    _cameraReady ? 'AI 분석 중' : '카메라 초기화 중',
                    style: AppTextStyles.caption.copyWith(
                      color: _cameraReady ? AppColors.success : AppColors.warning,
                    ),
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
            onPressed: () =>
                ref.read(_certificationProvider.notifier).togglePause(),
          ),
        ],
      ),
    );
  }

  // ── Timer ───────────────────────────────────────────────────────────────────

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
                  const AppLogo(size: AppSizes.characterSm + 10),
                  const SizedBox(height: AppSizes.spaceSm),
                  Text(
                    timeStr,
                    style: AppTextStyles.timerDisplay.copyWith(
                      fontSize: 42,
                      color: state.isPaused
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    state.isPaused ? '일시 정지됨' : '공부 중',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: state.isPaused
                          ? AppColors.textSecondary
                          : AppColors.success,
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

  // ── Camera section ──────────────────────────────────────────────────────────

  Widget _buildCameraSection(_CertificationState state) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraContent(),
            ..._buildCameraCorners(),
            if (state.faceResult?.faceDetected == true)
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
                      builder: (_, v, child) =>
                          Opacity(opacity: 0.5 + v * 0.5, child: child),
                    ),
              ),
            _buildScanOverlay(state),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildCameraContent() {
    if (_permissionDenied) {
      return ColoredBox(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_rounded,
                color: Colors.white54, size: 36),
            const SizedBox(height: 8),
            Text(
              '카메라 권한이 필요합니다',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: openAppSettings,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
                child: Text(
                  '설정 열기',
                  style: AppTextStyles.caption.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_cameraReady && _controller != null) {
      return CameraPreview(_controller!);
    }
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildScanOverlay(_CertificationState state) {
    final detected = state.faceResult?.faceDetected;
    final statusIcon = _isScanning
        ? null
        : detected == true
            ? Icons.check_circle_rounded
            : detected == false
                ? Icons.face_retouching_off_rounded
                : Icons.videocam_rounded;
    final statusColor = detected == true ? AppColors.success : Colors.white;
    final statusText = _isScanning
        ? 'AI 분석 중...'
        : detected == true
            ? '얼굴 인식 완료'
            : detected == false
                ? '얼굴 감지 실패'
                : 'AI 카메라 활성화됨';

    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isScanning)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                else
                  Icon(statusIcon, color: statusColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style:
                      AppTextStyles.caption.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          if (_cameraReady && !_isScanning) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _doScan,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '지금 인식',
                      style: AppTextStyles.caption.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCameraCorners() {
    const color = AppColors.primary;
    const length = 20.0;
    const strokeWidth = 3.0;

    return [
      Positioned(
        top: 12, left: 12,
        child: _CornerBracket(color: color, length: length, strokeWidth: strokeWidth, topLeft: true),
      ),
      Positioned(
        top: 12, right: 12,
        child: _CornerBracket(color: color, length: length, strokeWidth: strokeWidth, topRight: true),
      ),
      Positioned(
        bottom: 12, left: 12,
        child: _CornerBracket(color: color, length: length, strokeWidth: strokeWidth, bottomLeft: true),
      ),
      Positioned(
        bottom: 12, right: 12,
        child: _CornerBracket(color: color, length: length, strokeWidth: strokeWidth, bottomRight: true),
      ),
    ];
  }

  // ── Focus score ─────────────────────────────────────────────────────────────

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
              const Icon(Icons.track_changes_rounded,
                  color: AppColors.primary, size: AppSizes.iconLg),
              const SizedBox(width: AppSizes.spaceSm),
              Text('AI 집중도 분석', style: AppTextStyles.titleSmall),
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: score),
                duration: const Duration(milliseconds: 800),
                builder: (_, v, __) => Text(
                  '${v.toStringAsFixed(0)}점',
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
            state.lastScanAt == null
                ? '카메라로 얼굴을 인식하면 AI가 집중도를 분석합니다.'
                : score >= 80
                    ? '훌륭해요! 집중력이 매우 높습니다 🎉'
                    : score >= 60
                        ? '집중도가 보통입니다. 조금 더 집중해보세요!'
                        : '집중도가 낮습니다. 잠시 휴식을 취해보세요.',
            style: AppTextStyles.bodySmall.copyWith(
              color: state.lastScanAt == null ? AppColors.textSecondary : color,
            ),
          ),
          if (state.lastScanAt != null) ...[
            const SizedBox(height: 4),
            Text(
              '마지막 인식: ${_formatTime(state.lastScanAt!)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inSeconds;
    if (diff < 60) return '$diff초 전';
    return '${diff ~/ 60}분 전';
  }

  // ── Analysis list ────────────────────────────────────────────────────────────

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
              const Icon(Icons.analytics_rounded,
                  color: AppColors.primary, size: AppSizes.iconLg),
              const SizedBox(width: AppSizes.spaceSm),
              Text('AI 실시간 분석', style: AppTextStyles.titleSmall),
              const Spacer(),
              if (state.lastScanAt == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  ),
                  child: Text(
                    '분석 대기 중',
                    style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSizes.spaceSm),
          ...state.items.map(_buildAnalysisRow),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(_AnalysisItem item) {
    final (icon, color, bg) = switch (item.status) {
      _AnalysisStatus.ok =>
        (Icons.check_circle_rounded, AppColors.success, AppColors.successLight),
      _AnalysisStatus.warning =>
        (Icons.warning_rounded, AppColors.warning, AppColors.warningLight),
      _AnalysisStatus.error =>
        (Icons.error_rounded, AppColors.error, AppColors.errorLight),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXs),
      child: Row(
        children: [
          Text(
            item.label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceSm, vertical: 3),
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
                  style: AppTextStyles.caption
                      .copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Control buttons ──────────────────────────────────────────────────────────

  Widget _buildControlButtons(BuildContext context, _CertificationState state) {
    return Column(
      children: [
        AppButton(
          label: state.isPaused ? '공부 재개' : '일시 정지',
          variant:
              state.isPaused ? AppButtonVariant.primary : AppButtonVariant.outline,
          onPressed: () =>
              ref.read(_certificationProvider.notifier).togglePause(),
          icon: state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          size: AppButtonSize.large,
        ),
        const SizedBox(height: AppSizes.spaceMd),
        AppButton(
          label: '공부 종료',
          variant: AppButtonVariant.danger,
          onPressed: () => _showStopDialog(context),
          icon: Icons.stop_rounded,
          size: AppButtonSize.large,
        ),
      ],
    );
  }

  void _showStopDialog(BuildContext context) {
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              final st = ref.read(_certificationProvider);
              final minutes = st.elapsed.inMinutes;
              final awarded = await RewardsService.instance.recordStudySession(
                minutes: minutes,
                avgFocusScore: st.focusScore,
                subject: widget.subject,
              );
              // 오늘 공부했으므로 연속학습 경고 알림 취소.
              await NotificationService.instance.cancelStreakWarning();
              if (!context.mounted) return;
              if (awarded > 0) {
                await NotificationService.instance.notify(
                    '공부 완료 🎉', '$minutes분 공부로 $awarded포인트가 지급되었습니다!');
              }
              if (context.mounted) context.go('/home');
            },
            child:
                const Text('종료하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Corner bracket widget ────────────────────────────────────────────────────

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
