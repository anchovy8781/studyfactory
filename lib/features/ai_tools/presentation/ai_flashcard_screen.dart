import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';

class AiFlashcardScreen extends StatefulWidget {
  const AiFlashcardScreen({super.key});
  @override
  State<AiFlashcardScreen> createState() => _AiFlashcardScreenState();
}

class _AiFlashcardScreenState extends State<AiFlashcardScreen> {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final _aiService = ClaudeAiService();
  final _topicCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  int _count = 10;
  bool _loading = false;
  String? _error;
  List<_Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  void dispose() { _topicCtrl.dispose(); _detailCtrl.dispose(); super.dispose(); }

  Future<void> _generate() async {
    if (_topicCtrl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; _cards = []; _currentIndex = 0; _showAnswer = false; });
    try {
      final key = await _storage.read(key: 'claude_api_key') ?? '';
      if (key.isEmpty) { setState(() { _error = 'AI Coach 화면에서 API 키를 먼저 설정하세요.'; _loading = false; }); return; }
      final raw = await _aiService.generateFlashcards(apiKey: key, topic: _topicCtrl.text, count: _count, detail: _detailCtrl.text);
      setState(() { _cards = _parseCards(raw); });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  List<_Flashcard> _parseCards(String raw) {
    final cards = <_Flashcard>[];
    final blocks = raw.split(RegExp(r'\n(?=\d+\.)'));
    for (final block in blocks) {
      final qMatch = RegExp(r'Q:\s*(.+)', caseSensitive: false).firstMatch(block);
      final aMatch = RegExp(r'A:\s*(.+)', caseSensitive: false).firstMatch(block);
      if (qMatch != null && aMatch != null) {
        cards.add(_Flashcard(question: qMatch.group(1)!.trim(), answer: aMatch.group(1)!.trim()));
      }
    }
    return cards.isEmpty ? [_Flashcard(question: '카드를 불러오지 못했습니다', answer: raw)] : cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('AI 플래시카드'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceLg),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusLg), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(controller: _topicCtrl, decoration: const InputDecoration(labelText: '주제', hintText: '예) 전기회로 이론', border: OutlineInputBorder())),
                const SizedBox(height: AppSizes.spaceMd),
                TextField(controller: _detailCtrl, maxLines: 2, decoration: const InputDecoration(labelText: '세부 요청사항 (선택)', hintText: '예) 계산문제 위주, 초보자용 쉬운 설명', border: OutlineInputBorder())),
                const SizedBox(height: AppSizes.spaceMd),
                Row(children: [
                  Text('카드 수: $_count개', style: AppTextStyles.bodyMedium),
                  Expanded(child: Slider(value: _count.toDouble(), min: 5, max: 20, divisions: 3, onChanged: (v) => setState(() => _count = v.round()))),
                ]),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _generate,
                  icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.style_rounded),
                  label: Text(_loading ? '생성 중...' : '플래시카드 생성'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                ),
              ]),
            ),
            if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))],
            if (_cards.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spaceLg),
              Text('${_currentIndex + 1} / ${_cards.length}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSizes.spaceMd),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showAnswer = !_showAnswer),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.spaceLg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _showAnswer ? [const Color(0xFF10B981), const Color(0xFF059669)] : [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                      boxShadow: [BoxShadow(color: (_showAnswer ? const Color(0xFF10B981) : AppColors.primary).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_showAnswer ? Icons.lightbulb_rounded : Icons.help_outline_rounded, color: Colors.white, size: 40),
                        const SizedBox(height: AppSizes.spaceMd),
                        Text(_showAnswer ? '정답' : '문제', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                        const SizedBox(height: AppSizes.spaceSm),
                        Text(
                          _showAnswer ? _cards[_currentIndex].answer : _cards[_currentIndex].question,
                          style: AppTextStyles.titleMedium.copyWith(color: Colors.white, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.spaceLg),
                        Text(_showAnswer ? '탭하여 다음 문제' : '탭하여 정답 보기', style: AppTextStyles.bodySmall.copyWith(color: Colors.white60)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceMd),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(onPressed: _currentIndex > 0 ? () => setState(() { _currentIndex--; _showAnswer = false; }) : null, icon: const Icon(Icons.arrow_back_rounded)),
                Row(children: [
                  TextButton(onPressed: () => setState(() { _currentIndex = 0; _showAnswer = false; }), child: const Text('처음부터')),
                ]),
                IconButton(onPressed: _currentIndex < _cards.length - 1 ? () => setState(() { _currentIndex++; _showAnswer = false; }) : null, icon: const Icon(Icons.arrow_forward_rounded)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

class _Flashcard { const _Flashcard({required this.question, required this.answer}); final String question; final String answer; }
