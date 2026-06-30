import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';

/// Photo → AI 채점 & 해설.
///
/// 학생이 푼 문제(시험지·문제집·필기)를 촬영하면 Gemini 비전이 정답 여부를
/// 채점하고 각 문제의 풀이·해설을 제공합니다.
class AiGradingScreen extends StatefulWidget {
  const AiGradingScreen({super.key});
  @override
  State<AiGradingScreen> createState() => _AiGradingScreenState();
}

class _AiGradingScreenState extends State<AiGradingScreen> {
  static const _storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _ai = ClaudeAiService();
  final _picker = ImagePicker();
  final _detailCtrl = TextEditingController();
  File? _image;
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() {
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final xf = await _picker.pickImage(source: source, imageQuality: 85);
      if (xf == null) return;
      setState(() {
        _image = File(xf.path);
        _result = null;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = '이미지를 가져오지 못했습니다: $e');
    }
  }

  Future<void> _grade() async {
    if (_image == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final key = await _storage.read(key: 'claude_api_key') ?? '';
      if (key.isEmpty) {
        setState(() {
          _error = 'AI Coach 화면에서 API 키를 먼저 설정하세요.';
          _loading = false;
        });
        return;
      }
      final bytes = await _image!.readAsBytes();
      final result = await _ai.analyzeImage(
        apiKey: key,
        imageBytes: bytes,
        task: '사진 속 문제와 학생이 작성한 답을 인식하여 채점하세요. '
            '각 문제마다 (1) 문제 번호, (2) 정답 여부(⭕/❌), (3) 정답, '
            '(4) 풀이 과정과 해설을 한국어로 명확히 작성하고, 마지막에 총점/맞은 개수를 요약하세요.',
        detail: _detailCtrl.text,
      );
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('AI 채점 & 해설'),
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_image == null)
            Container(
              height: 200,
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.border)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fact_check_rounded,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: AppSizes.spaceSm),
                    Text('푼 문제를 촬영하면 AI가 채점·해설해드려요',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ]),
            )
          else
            ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                child: Image.file(_image!, height: 220, fit: BoxFit.cover)),
          const SizedBox(height: AppSizes.spaceMd),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('카메라'))),
            const SizedBox(width: 12),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('갤러리'))),
          ]),
          const SizedBox(height: AppSizes.spaceMd),
          TextField(
            controller: _detailCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
                labelText: '추가 요청 (선택)',
                hintText: '예) 수학 풀이 자세히 / 영어 문법 위주로 설명',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: AppSizes.spaceMd),
          ElevatedButton.icon(
            onPressed: (_loading || _image == null) ? null : _grade,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_fix_high_rounded),
            label: Text(_loading ? 'AI 채점 중...' : 'AI로 채점하기'),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(_error!,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error))),
          ],
          if (_result != null) ...[
            const SizedBox(height: AppSizes.spaceLg),
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceLg),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: AppColors.cardShadow),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.grading_rounded,
                          color: Color(0xFF7C3AED)),
                      const SizedBox(width: 8),
                      Text('채점 결과 & 해설',
                          style: AppTextStyles.titleMedium),
                    ]),
                    const SizedBox(height: AppSizes.spaceMd),
                    SelectableText(_result!,
                        style:
                            AppTextStyles.bodyMedium.copyWith(height: 1.6)),
                  ]),
            ),
          ],
        ]),
      ),
    );
  }
}
