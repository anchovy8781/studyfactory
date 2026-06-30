import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';

class AiOcrScreen extends StatefulWidget {
  const AiOcrScreen({super.key});
  @override
  State<AiOcrScreen> createState() => _AiOcrScreenState();
}

class _AiOcrScreenState extends State<AiOcrScreen> {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _aiService = ClaudeAiService();
  final _picker = ImagePicker();
  final _commandCtrl = TextEditingController();
  File? _image;
  String _task = '핵심 내용 요약';
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() {
    _commandCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xf = await _picker.pickImage(source: source, imageQuality: 85);
      if (xf == null) return;
      setState(() { _image = File(xf.path); _result = null; _error = null; });
    } catch (e) {
      setState(() => _error = '이미지를 가져오지 못했습니다: $e');
    }
  }

  Future<void> _analyze() async {
    if (_image == null) return;
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final key = await _storage.read(key: 'claude_api_key') ?? '';
      if (key.isEmpty) { setState(() { _error = 'AI Coach 화면에서 API 키를 먼저 설정하세요.'; _loading = false; }); return; }
      // Real OCR + understanding via Gemini vision (the actual photo is sent).
      final bytes = await _image!.readAsBytes();
      final analysis = await _aiService.analyzeImage(
        apiKey: key,
        imageBytes: bytes,
        task: _task,
        detail: _commandCtrl.text,
      );
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
      appBar: AppBar(title: const Text('OCR 스캔 & AI 분석'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_image == null) ...[
            Container(
              height: 200,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: AppColors.border, style: BorderStyle.solid)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.document_scanner_rounded, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: AppSizes.spaceSm),
                Text('프린트물이나 교재를 촬영하세요', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ]),
            ),
          ] else ...[
            ClipRRect(borderRadius: BorderRadius.circular(AppSizes.radiusLg), child: Image.file(_image!, height: 200, fit: BoxFit.cover)),
          ],
          const SizedBox(height: AppSizes.spaceMd),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt_rounded), label: const Text('카메라'))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library_rounded), label: const Text('갤러리'))),
          ]),
          const SizedBox(height: AppSizes.spaceMd),
          Text('AI 작업', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSizes.spaceXs),
          Wrap(spacing: 8, runSpacing: 8, children: ['핵심 내용 요약', '예상문제 생성', '개념 설명', '키워드 추출', '문제 풀이', '번역'].map((t) => ChoiceChip(label: Text(t), selected: _task == t, onSelected: (_) => setState(() => _task = t))).toList()),
          const SizedBox(height: AppSizes.spaceMd),
          TextField(controller: _commandCtrl, maxLines: 2, decoration: const InputDecoration(labelText: '구체적 명령 (선택)', hintText: '예) 3번 문제만 풀어줘 / 영어를 한국어로 번역 / 표로 정리', border: OutlineInputBorder())),
          const SizedBox(height: AppSizes.spaceMd),
          ElevatedButton.icon(
            onPressed: (_loading || _image == null) ? null : _analyze,
            icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.auto_fix_high_rounded),
            label: Text(_loading ? 'AI 분석 중...' : 'AI로 분석하기'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06B6D4), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
          if (_error != null) ...[const SizedBox(height: 12), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(8)), child: Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)))],
          if (_result != null) ...[
            const SizedBox(height: AppSizes.spaceLg),
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceLg),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.auto_awesome_rounded, color: Color(0xFF06B6D4)), const SizedBox(width: 8), Text('AI 분석 결과', style: AppTextStyles.titleMedium)]),
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
