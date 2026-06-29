import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';

class AiVoiceScreen extends StatefulWidget {
  const AiVoiceScreen({super.key});
  @override
  State<AiVoiceScreen> createState() => _AiVoiceScreenState();
}

class _AiVoiceScreenState extends State<AiVoiceScreen> {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _aiService = ClaudeAiService();
  final _questionCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() { _questionCtrl.dispose(); _subjectCtrl.dispose(); super.dispose(); }

  Future<void> _ask() async {
    if (_questionCtrl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final key = await _storage.read(key: 'claude_api_key') ?? '';
      if (key.isEmpty) { setState(() { _error = 'AI Coach 화면에서 API 키를 먼저 설정하세요.'; _loading = false; }); return; }
      final answer = await _aiService.answerVoiceQuestion(apiKey: key, question: _questionCtrl.text, subject: _subjectCtrl.text.isEmpty ? '일반' : _subjectCtrl.text);
      setState(() { _result = answer; });
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
      appBar: AppBar(title: const Text('AI 질문 답변'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(children: [
              const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 48),
              const SizedBox(height: 8),
              Text('AI에게 질문하기', style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
              Text('모르는 것을 입력하면 AI가 답변합니다', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: AppSizes.spaceLg),
          TextField(controller: _subjectCtrl, decoration: const InputDecoration(labelText: '과목 (선택)', hintText: '예) 수학, 물리', border: OutlineInputBorder())),
          const SizedBox(height: AppSizes.spaceMd),
          TextField(controller: _questionCtrl, decoration: const InputDecoration(labelText: '질문 내용', hintText: '모르는 개념이나 문제를 입력하세요', border: OutlineInputBorder()), maxLines: 4),
          const SizedBox(height: AppSizes.spaceMd),
          ElevatedButton.icon(
            onPressed: _loading ? null : _ask,
            icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
            label: Text(_loading ? 'AI 답변 생성 중...' : 'AI에게 물어보기'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
          if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))],
          if (_result != null) ...[
            const SizedBox(height: AppSizes.spaceLg),
            Expanded(child: Container(
              padding: const EdgeInsets.all(AppSizes.spaceLg),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
              child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6)), const SizedBox(width: 8), Text('AI 답변', style: AppTextStyles.titleMedium)]),
                const SizedBox(height: AppSizes.spaceMd),
                Text(_result!, style: AppTextStyles.bodyMedium.copyWith(height: 1.7)),
              ])),
            )),
          ],
        ]),
      ),
    );
  }
}
