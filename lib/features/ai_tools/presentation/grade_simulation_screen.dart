import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';

class GradeSimulationScreen extends StatefulWidget {
  const GradeSimulationScreen({super.key});
  @override
  State<GradeSimulationScreen> createState() => _GradeSimulationScreenState();
}

class _GradeSimulationScreenState extends State<GradeSimulationScreen> {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _aiService = ClaudeAiService();
  final _subjectCtrl = TextEditingController();
  final _examDateCtrl = TextEditingController();
  int _studyHours = 50;
  double _focusScore = 75;
  String _targetGrade = '1등급';
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() { _subjectCtrl.dispose(); _examDateCtrl.dispose(); super.dispose(); }

  Future<void> _simulate() async {
    if (_subjectCtrl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final key = await _storage.read(key: 'claude_api_key') ?? '';
      if (key.isEmpty) { setState(() { _error = 'AI Coach 화면에서 API 키를 먼저 설정하세요.'; _loading = false; }); return; }
      final result = await _aiService.simulateGrade(apiKey: key, subject: _subjectCtrl.text, totalStudyHours: _studyHours, avgFocusScore: _focusScore, targetGrade: _targetGrade, examDate: _examDateCtrl.text.isEmpty ? '미정' : _examDateCtrl.text);
      setState(() { _result = result; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('등급 시뮬레이션'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(controller: _subjectCtrl, decoration: const InputDecoration(labelText: '과목 / 시험', border: OutlineInputBorder())),
              const SizedBox(height: AppSizes.spaceMd),
              TextField(controller: _examDateCtrl, decoration: const InputDecoration(labelText: '시험 날짜 (선택)', hintText: '예) 2025년 9월', border: OutlineInputBorder())),
              const SizedBox(height: AppSizes.spaceMd),
              Text('누적 공부 시간: ${_studyHours}시간', style: AppTextStyles.bodyMedium),
              Slider(value: _studyHours.toDouble(), min: 10, max: 500, divisions: 49, onChanged: (v) => setState(() => _studyHours = v.round())),
              Text('평균 집중도: ${_focusScore.toInt()}점', style: AppTextStyles.bodyMedium),
              Slider(value: _focusScore, min: 0, max: 100, onChanged: (v) => setState(() => _focusScore = v)),
              const SizedBox(height: AppSizes.spaceSm),
              Text('목표 등급', style: AppTextStyles.titleSmall),
              const SizedBox(height: AppSizes.spaceXs),
              Wrap(spacing: 8, children: ['1등급', '2등급', '3등급', '합격'].map((g) => ChoiceChip(label: Text(g), selected: _targetGrade == g, onSelected: (_) => setState(() => _targetGrade = g))).toList()),
              const SizedBox(height: AppSizes.spaceMd),
              ElevatedButton.icon(
                onPressed: _loading ? null : _simulate,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.trending_up_rounded),
                label: Text(_loading ? '분석 중...' : 'AI 등급 시뮬레이션'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ]),
          ),
          if (_error != null) ...[const SizedBox(height: 12), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(8)), child: Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)))],
          if (_result != null) ...[
            const SizedBox(height: AppSizes.spaceLg),
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceLg),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.trending_up_rounded, color: Color(0xFF3B82F6)), const SizedBox(width: 8), Text('AI 시뮬레이션 결과', style: AppTextStyles.titleMedium)]),
                const SizedBox(height: AppSizes.spaceMd),
                Text(_result!, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
