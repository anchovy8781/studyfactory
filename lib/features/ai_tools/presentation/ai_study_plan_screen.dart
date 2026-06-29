import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';

class AiStudyPlanScreen extends ConsumerStatefulWidget {
  const AiStudyPlanScreen({super.key});
  @override
  ConsumerState<AiStudyPlanScreen> createState() => _AiStudyPlanScreenState();
}

class _AiStudyPlanScreenState extends ConsumerState<AiStudyPlanScreen> {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _aiService = ClaudeAiService();
  final _subjectCtrl = TextEditingController();
  final _examDateCtrl = TextEditingController();
  int _dailyHours = 3;
  String _level = '중간';
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _examDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_subjectCtrl.text.isEmpty || _examDateCtrl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final key = await _storage.read(key: 'claude_api_key') ?? '';
      if (key.isEmpty) { setState(() { _error = 'AI Coach 화면에서 API 키를 먼저 설정하세요.'; _loading = false; }); return; }
      final plan = await _aiService.generateStudyPlan(
        apiKey: key,
        subject: _subjectCtrl.text,
        examDate: _examDateCtrl.text,
        dailyHours: _dailyHours,
        currentLevel: _level,
      );
      setState(() { _result = plan; });
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
      appBar: AppBar(
        title: const Text('AI 학습 계획'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(children: [
              Text('학습 정보 입력', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSizes.spaceMd),
              TextField(controller: _subjectCtrl, decoration: const InputDecoration(labelText: '과목 / 시험명', hintText: '예) 전기기사, 수능 수학', border: OutlineInputBorder())),
              const SizedBox(height: AppSizes.spaceMd),
              TextField(controller: _examDateCtrl, decoration: const InputDecoration(labelText: '시험 날짜', hintText: '예) 2025년 9월 15일', border: OutlineInputBorder())),
              const SizedBox(height: AppSizes.spaceMd),
              Row(children: [
                Text('하루 공부 시간: ${_dailyHours}시간', style: AppTextStyles.bodyMedium),
                Expanded(child: Slider(value: _dailyHours.toDouble(), min: 1, max: 10, divisions: 9, onChanged: (v) => setState(() => _dailyHours = v.round()))),
              ]),
              const SizedBox(height: AppSizes.spaceSm),
              Text('현재 수준', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSizes.spaceXs),
              Wrap(spacing: 8, children: ['초급', '중간', '고급'].map((l) => ChoiceChip(label: Text(l), selected: _level == l, onSelected: (_) => setState(() => _level = l))).toList()),
            ]),
            const SizedBox(height: AppSizes.spaceMd),
            ElevatedButton.icon(
              onPressed: _loading ? null : _generate,
              icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.auto_fix_high_rounded),
              label: Text(_loading ? 'AI 분석 중...' : 'AI 학습 계획 생성'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSizes.spaceMd),
              Container(padding: const EdgeInsets.all(AppSizes.spaceMd), decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(AppSizes.radiusMd)), child: Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))),
            ],
            if (_result != null) ...[
              const SizedBox(height: AppSizes.spaceLg),
              _buildCard(children: [
                Row(children: [
                  const Icon(Icons.auto_stories_rounded, color: Color(0xFF6366F1)),
                  const SizedBox(width: 8),
                  Text('AI 학습 계획', style: AppTextStyles.titleMedium),
                ]),
                const SizedBox(height: AppSizes.spaceMd),
                Text(_result!, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
