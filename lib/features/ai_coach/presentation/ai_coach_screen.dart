import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/core/services/claude_ai_service.dart';
import 'package:studyverse/shared/widgets/app_button.dart';

// ── Chat message model ────────────────────────────────────────────────────────

class _ChatMessage {
  const _ChatMessage({required this.isUser, required this.text});
  final bool isUser;
  final String text;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _apiKeyStorageKey = 'claude_api_key';

  final ClaudeAiService _aiService = ClaudeAiService();
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String? _apiKey;
  bool _isLoading = false;
  final List<_ChatMessage> _messages = [];

  // Mock study data (will be replaced with real Riverpod providers)
  static const _todayMinutes = 95;
  static const _weekMinutes = 420;
  static const double _focusScore = 87.0;
  static const _topSubject = '전기기사';

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    try {
      final key = await _storage.read(key: _apiKeyStorageKey);
      if (mounted) setState(() => _apiKey = key);
    } catch (e) {
      debugPrint('[AiCoach] storage read: $e');
    }
  }

  Future<void> _saveApiKey(String key) async {
    await _storage.write(key: _apiKeyStorageKey, value: key);
    if (mounted) setState(() => _apiKey = key.trim());
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading || _apiKey == null) return;

    _inputCtrl.clear();
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: trimmed));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final reply = await _aiService.ask(
        apiKey: _apiKey!,
        question: trimmed,
        todayMinutes: _todayMinutes,
        weekMinutes: _weekMinutes,
        focusScore: _focusScore,
        topSubject: _topSubject,
      );
      if (mounted) {
        setState(() => _messages.add(_ChatMessage(isUser: false, text: reply)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _messages.add(
              _ChatMessage(isUser: false, text: e.toString().replaceAll('Exception: ', '')),
            ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('AI 공부 코치', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: Icon(
              _apiKey != null && _apiKey!.isNotEmpty
                  ? Icons.key_rounded
                  : Icons.key_off_rounded,
              color: _apiKey != null && _apiKey!.isNotEmpty
                  ? AppColors.success
                  : AppColors.warning,
            ),
            onPressed: _showApiKeyDialog,
            tooltip: 'Gemini API 키 설정',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingCard(),
                  const SizedBox(height: 16),
                  _buildAnalysisCard(),
                  const SizedBox(height: 16),
                  _buildWeeklyGoalCard(),
                  const SizedBox(height: 16),
                  _buildChatSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── Greeting card ─────────────────────────────────────────────────────────

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF4A90D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘의 공부 분석이에요!',
                    style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('오늘도 열심히 공부하고 있네요 🎉',
                    style:
                        AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _apiKey != null && _apiKey!.isNotEmpty
                        ? 'AI 코치 연결됨 ✓'
                        : 'API 키 설정 필요',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: _apiKey != null && _apiKey!.isNotEmpty
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white38, width: 2),
            ),
            child: const Center(
              child: Text('🐶', style: TextStyle(fontSize: 40)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  // ── Analysis card ──────────────────────────────────────────────────────────

  Widget _buildAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('오늘의 분석',
                  style: AppTextStyles.titleSmall
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisMetric(
            label: '집중도',
            value: '${_focusScore.toInt()}점',
            progress: _focusScore / 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.star_rounded,
            iconColor: AppColors.warning,
            label: '가장 많이 공부한 과목',
            value: _topSubject,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.timer_rounded,
            iconColor: AppColors.primary,
            label: '오늘 공부 시간',
            value: '${_todayMinutes ~/ 60}시간 ${_todayMinutes % 60}분',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildAnalysisMetric({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            Text(value,
                style: AppTextStyles.titleSmall
                    .copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Text(label,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Weekly goal card ───────────────────────────────────────────────────────

  Widget _buildWeeklyGoalCard() {
    const goalHours = 30.0;
    const doneHours = _weekMinutes / 60;
    final progress = doneHours / goalHours;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text('이번 주 목표',
                  style: AppTextStyles.titleSmall
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text('주간 순공 시간 목표',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${doneHours.toInt()}시간',
                  style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('/ ${goalHours.toInt()}시간',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toInt()}% 달성',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
              Text(
                  progress >= 1
                      ? '목표 달성! 🎉'
                      : '목표까지 ${(goalHours - doneHours).toInt()}시간 남았어요',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  // ── Chat section ───────────────────────────────────────────────────────────

  Widget _buildChatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.chat_bubble_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('AI 코치에게 질문하기',
                style: AppTextStyles.titleSmall
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _apiKey != null && _apiKey!.isNotEmpty
              ? 'Gemini AI가 공부 데이터를 분석해 실시간으로 답변합니다.'
              : '우상단 키 아이콘을 눌러 Gemini API 키를 입력하세요.',
          style: AppTextStyles.bodySmall.copyWith(
            color: _apiKey != null && _apiKey!.isNotEmpty
                ? AppColors.textSecondary
                : AppColors.warning,
          ),
        ),
        const SizedBox(height: 12),

        // Quick question chips
        if (_apiKey != null && _apiKey!.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickChip('오늘 공부 어떻게 됐어?'),
              _buildQuickChip('집중력 높이는 방법'),
              _buildQuickChip('다음에 뭘 공부할까?'),
              _buildQuickChip('휴식 언제 취할까?'),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Chat messages
        if (_messages.isEmpty && (_apiKey == null || _apiKey!.isEmpty))
          _buildApiKeyPrompt()
        else if (_messages.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                const Icon(Icons.smart_toy_rounded,
                    color: AppColors.primary, size: 40),
                const SizedBox(height: 12),
                Text(
                  '안녕하세요! 공부에 대해 무엇이든 물어보세요 😊\n데이터를 분석해 맞춤형 조언을 드릴게요.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ..._messages.asMap().entries.map((e) {
            final i = e.key;
            final msg = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildChatBubble(msg).animate()
                .slideY(begin: 0.2, duration: 250.ms, delay: (i * 30).ms)
                .fadeIn(),
            );
          }),

        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text('AI 분석 중...',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickChip(String label) {
    return GestureDetector(
      onTap: () => _sendMessage(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Text(
          msg.text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildApiKeyPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.key_rounded, color: AppColors.warning, size: 36),
          const SizedBox(height: 10),
          Text(
            'Gemini API 키가 필요합니다',
            style: AppTextStyles.titleSmall
                .copyWith(color: AppColors.warning, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Google AI Studio(aistudio.google.com)에서\n무료 API 키를 발급받아 우상단 키 아이콘으로 입력하세요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'API 키 입력',
            onPressed: _showApiKeyDialog,
            icon: Icons.key_rounded,
          ),
        ],
      ),
    );
  }

  // ── Input bar ───────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              enabled: _apiKey != null && _apiKey!.isNotEmpty && !_isLoading,
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: _apiKey != null && _apiKey!.isNotEmpty
                    ? '공부에 대해 질문해보세요...'
                    : 'API 키를 먼저 설정해주세요',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _apiKey != null && _apiKey!.isNotEmpty && !_isLoading
                ? () => _sendMessage(_inputCtrl.text)
                : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _apiKey != null && _apiKey!.isNotEmpty && !_isLoading
                    ? AppColors.primary
                    : AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── API key dialog ───────────────────────────────────────────────────────────

  void _showApiKeyDialog() {
    final ctrl = TextEditingController(text: _apiKey ?? '');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Gemini API 키 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Google AI Studio (aistudio.google.com)에서\n무료 API 키를 발급받아 입력하세요.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'sk-ant-...',
                hintStyle: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.key_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          if (_apiKey != null && _apiKey!.isNotEmpty)
            TextButton(
              onPressed: () async {
                await _storage.delete(key: _apiKeyStorageKey);
                if (mounted) setState(() => _apiKey = null);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text('삭제', style: TextStyle(color: AppColors.error)),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await _saveApiKey(ctrl.text);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
