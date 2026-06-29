import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';

class AiWrongAnswerScreen extends StatefulWidget {
  const AiWrongAnswerScreen({super.key});
  @override
  State<AiWrongAnswerScreen> createState() => _AiWrongAnswerScreenState();
}

class _AiWrongAnswerScreenState extends State<AiWrongAnswerScreen> {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _aiService = ClaudeAiService();
  final _subjectCtrl = TextEditingController();
  final _questionCtrl = TextEditingController();
  final List<String> _wrongQuestions = [];
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() { _subjectCtrl.dispose(); _questionCtrl.dispose(); super.dispose(); }

  void _addQuestion() {
    if (_questionCtrl.text.trim().isEmpty) return;
    setState(() { _wrongQuestions.add(_questionCtrl.text.trim()); _questionCtrl.clear(); });
  }

  Future<void> _analyze() async {
    if (_subjectCtrl.text.isEmpty || _wrongQuestions.isEmpty) return;
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final key = await _storage.read(key: 'claude_api_key') ?? '';
      if (key.isEmpty) { setState(() { _error = 'AI Coach 화면에서 API 키를 먼저 설정하세요.'; _loading = false; }); return; }
      final analysis = await _aiService.analyzeWrongAnswers(apiKey: key, subject: _subjectCtrl.text, wrongQuestions: _wrongQuestions);
      setState(() { _result = analysis; });
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
      appBar: AppBar(title: const Text('AI 오답노트'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _card(children: [
            TextField(controller: _subjectCtrl, decoration: const InputDecoration(labelText: '과목', border: OutlineInputBorder())),
            const SizedBox(height: AppSizes.spaceMd),
            Text('틀린 문제 추가 (${_wrongQuestions.length}개)', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSizes.spaceSm),
            Row(children: [
              Expanded(child: TextField(controller: _questionCtrl, decoration: const InputDecoration(hintText: '틀린 문제 또는 유형 입력', border: OutlineInputBorder()), onSubmitted: (_) => _addQuestion())),
              const SizedBox(width: 8),
              IconButton(onPressed: _addQuestion, icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 32)),
            ]),
            if (_wrongQuestions.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spaceSm),
              ..._wrongQuestions.asMap().entries.map((e) => ListTile(
                dense: true,
                leading: CircleAvatar(radius: 12, backgroundColor: const Color(0xFFEC4899), child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 10))),
                title: Text(e.value, style: AppTextStyles.bodyMedium),
                trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _wrongQuestions.removeAt(e.key))),
              )),
            ],
          ]),
          const SizedBox(height: AppSizes.spaceMd),
          ElevatedButton.icon(
            onPressed: (_loading || _wrongQuestions.isEmpty) ? null : _analyze,
            icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.psychology_rounded),
            label: Text(_loading ? 'AI 분석 중...' : 'AI 오답 분석'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
          if (_error != null) ...[const SizedBox(height: 12), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(8)), child: Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)))],
          if (_result != null) ...[
            const SizedBox(height: AppSizes.spaceLg),
            _card(children: [
              Row(children: [const Icon(Icons.psychology_rounded, color: Color(0xFFEC4899)), const SizedBox(width: 8), Text('AI 분석 결과', style: AppTextStyles.titleMedium)]),
              const SizedBox(height: AppSizes.spaceMd),
              Text(_result!, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _card({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(AppSizes.spaceLg),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}
