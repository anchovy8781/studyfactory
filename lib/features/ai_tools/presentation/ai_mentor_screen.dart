import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';

class AiMentorScreen extends StatefulWidget {
  const AiMentorScreen({super.key});
  @override
  State<AiMentorScreen> createState() => _AiMentorScreenState();
}

class _AiMentorScreenState extends State<AiMentorScreen> {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _aiService = ClaudeAiService();
  final _weaknessCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  int _daysLeft = 30;
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() { _weaknessCtrl.dispose(); _goalCtrl.dispose(); super.dispose(); }

  Future<void> _startMentoring() async {
    if (_weaknessCtrl.text.isEmpty || _goalCtrl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final key = await _storage.read(key: 'claude_api_key') ?? '';
      if (key.isEmpty) { setState(() { _error = 'AI Coach 화면에서 API 키를 먼저 설정하세요.'; _loading = false; }); return; }
      final plan = await _aiService.mentorCoach(apiKey: key, weakness: _weaknessCtrl.text, goal: _goalCtrl.text, daysLeft: _daysLeft);
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
      appBar: AppBar(title: const Text('AI 멘토 모드'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Row(children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 40),
              const SizedBox(width: AppSizes.spaceMd),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AI 멘토 모드', style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
                Text('약점을 집중 공략하는 맞춤 코칭', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              ])),
            ]),
          ),
          const SizedBox(height: AppSizes.spaceLg),
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(controller: _weaknessCtrl, decoration: const InputDecoration(labelText: '나의 약점 영역', hintText: '예) 수학 미적분, 영어 독해', border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: AppSizes.spaceMd),
              TextField(controller: _goalCtrl, decoration: const InputDecoration(labelText: '최종 목표', hintText: '예) 수능 수학 1등급, 전기기사 합격', border: OutlineInputBorder())),
              const SizedBox(height: AppSizes.spaceMd),
              Text('남은 기간: D-$_daysLeft', style: AppTextStyles.bodyMedium),
              Slider(value: _daysLeft.toDouble(), min: 7, max: 180, divisions: 173, onChanged: (v) => setState(() => _daysLeft = v.round()), activeColor: const Color(0xFFEF4444)),
              const SizedBox(height: AppSizes.spaceSm),
              ElevatedButton.icon(
                onPressed: _loading ? null : _startMentoring,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.school_rounded),
                label: Text(_loading ? 'AI 분석 중...' : 'AI 멘토링 시작'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
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
                Row(children: [const Icon(Icons.school_rounded, color: Color(0xFFEF4444)), const SizedBox(width: 8), Text('맞춤 멘토링 플랜', style: AppTextStyles.titleMedium)]),
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
