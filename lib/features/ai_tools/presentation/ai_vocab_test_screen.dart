import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';

/// AI-generated English vocabulary test (4-choice).
class AiVocabTestScreen extends StatefulWidget {
  const AiVocabTestScreen({super.key});
  @override
  State<AiVocabTestScreen> createState() => _AiVocabTestScreenState();
}

class _Question {
  _Question(this.word, this.answer, this.options);
  final String word;
  final String answer;
  final List<String> options; // shuffled, includes answer
}

class _AiVocabTestScreenState extends State<AiVocabTestScreen> {
  static const _storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _ai = ClaudeAiService();

  final _levels = ['초급', '중급', '고급', '수능', '토익'];
  String _level = '중급';
  int _count = 10;

  bool _loading = false;
  String? _error;
  List<_Question> _questions = [];
  int _index = 0;
  int _score = 0;
  String? _picked; // currently selected option for this question
  bool _finished = false;

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
      _questions = [];
      _index = 0;
      _score = 0;
      _picked = null;
      _finished = false;
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
      final raw =
          await _ai.generateVocabTest(apiKey: key, level: _level, count: _count);
      final qs = _parse(raw);
      if (qs.isEmpty) {
        setState(() => _error = '문제를 생성하지 못했습니다. 다시 시도해주세요.');
      } else {
        setState(() => _questions = qs);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_Question> _parse(String raw) {
    final rng = Random();
    final out = <_Question>[];
    for (final line in raw.split('\n')) {
      final parts = line.split('|');
      if (parts.length < 3) continue;
      final word = parts[0].trim();
      final answer = parts[1].trim();
      final wrongs = parts[2]
          .split(RegExp(r'[;,]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (word.isEmpty || answer.isEmpty || wrongs.length < 2) continue;
      final opts = <String>[answer, ...wrongs.take(3)]..shuffle(rng);
      out.add(_Question(word, answer, opts));
    }
    return out;
  }

  void _pick(String option) {
    if (_picked != null) return; // already answered
    setState(() {
      _picked = option;
      if (option == _questions[_index].answer) _score++;
    });
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _picked = null;
      });
    } else {
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('AI 영어 단어 시험'),
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: _questions.isEmpty ? _buildSetup() : _buildQuiz(),
      ),
    );
  }

  Widget _buildSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.spaceLg),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              boxShadow: AppColors.cardShadow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('난이도', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _levels.map((l) {
                  final sel = l == _level;
                  return ChoiceChip(
                    label: Text(l),
                    selected: sel,
                    onSelected: (_) => setState(() => _level = l),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.textSecondary),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Text('문제 수: $_count개', style: AppTextStyles.bodyMedium),
                Expanded(
                  child: Slider(
                    value: _count.toDouble(),
                    min: 5,
                    max: 20,
                    divisions: 3,
                    onChanged: (v) => setState(() => _count = v.round()),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _start,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.quiz_rounded),
                  label: Text(_loading ? '문제 생성 중...' : '시험 시작'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
        ],
      ],
    );
  }

  Widget _buildQuiz() {
    if (_finished) return _buildResult();
    final q = _questions[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: (_index + 1) / _questions.length,
          backgroundColor: AppColors.surfaceVariant,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        Text('${_index + 1} / ${_questions.length}   ·   점수 $_score',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark]),
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          child: Center(
            child: Text(q.word,
                style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 20),
        ...q.options.map((opt) {
          final answered = _picked != null;
          final isAnswer = opt == q.answer;
          final isPicked = opt == _picked;
          Color bg = AppColors.surface;
          Color border = AppColors.border;
          if (answered && isAnswer) {
            bg = AppColors.success.withOpacity(0.12);
            border = AppColors.success;
          } else if (answered && isPicked && !isAnswer) {
            bg = AppColors.error.withOpacity(0.12);
            border = AppColors.error;
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _pick(opt),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(opt, style: AppTextStyles.bodyLarge)),
                    if (answered && isAnswer)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 20),
                    if (answered && isPicked && !isAnswer)
                      const Icon(Icons.cancel_rounded,
                          color: AppColors.error, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        if (_picked != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              child: Text(
                  _index < _questions.length - 1 ? '다음 문제' : '결과 보기'),
            ),
          ),
      ],
    );
  }

  Widget _buildResult() {
    final total = _questions.length;
    final pct = total == 0 ? 0 : (_score / total * 100).round();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(pct >= 80 ? '🎉' : (pct >= 50 ? '👍' : '💪'),
              style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('$total문제 중 $_score문제 정답',
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('정답률 $pct%',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => setState(() {
              _questions = [];
              _finished = false;
            }),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('새 시험 보기'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
