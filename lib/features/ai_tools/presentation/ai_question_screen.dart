import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';

class AiQuestionScreen extends StatefulWidget {
  const AiQuestionScreen({super.key});
  @override
  State<AiQuestionScreen> createState() => _AiQuestionScreenState();
}

class _AiQuestionScreenState extends State<AiQuestionScreen> {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _aiService = ClaudeAiService();
  final _topicCtrl = TextEditingController();
  String _difficulty = '중간';
  int _count = 5;
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() { _topicCtrl.dispose(); super.dispose(); }

  Future<void> _generate() async {
    if (_topicCtrl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final key = await _storage.read(key: 'claude_api_key') ?? '';
      if (key.isEmpty) { setState(() { _error = 'AI Coach 화면에서 API 키를 먼저 설정하세요.'; _loading = false; }); return; }
      final questions = await _aiService.generateQuestions(apiKey: key, topic: _topicCtrl.text, difficulty: _difficulty, count: _count);
      setState(() { _result = questions; });
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
      appBar: AppBar(title: const Text('AI 예상문제'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(controller: _topicCtrl, decoration: const InputDecoration(labelText: '주제 / 단원', hintText: '예) 전기자기학 맥스웰 방정식', border: OutlineInputBorder())),
              const SizedBox(height: AppSizes.spaceMd),
              Text('난이도', style: AppTextStyles.titleSmall),
              const SizedBox(height: AppSizes.spaceXs),
              Wrap(spacing: 8, children: ['쉬움', '중간', '어려움'].map((d) => ChoiceChip(label: Text(d), selected: _difficulty == d, onSelected: (_) => setState(() => _difficulty = d))).toList()),
              const SizedBox(height: AppSizes.spaceMd),
              Row(children: [
                Text('문제 수: $_count개', style: AppTextStyles.bodyMedium),
                Expanded(child: Slider(value: _count.toDouble(), min: 3, max: 10, divisions: 7, onChanged: (v) => setState(() => _count = v.round()))),
              ]),
              ElevatedButton.icon(
                onPressed: _loading ? null : _generate,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.quiz_rounded),
                label: Text(_loading ? 'AI 출제 중...' : 'AI 문제 생성'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
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
                Row(children: [const Icon(Icons.quiz_rounded, color: Color(0xFFF59E0B)), const SizedBox(width: 8), Text('생성된 문제', style: AppTextStyles.titleMedium)]),
                const SizedBox(height: AppSizes.spaceMd),
                Text(_result!, style: AppTextStyles.bodyMedium.copyWith(height: 1.7)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
