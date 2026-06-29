import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ClaudeAiService {
  static const _url = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-haiku-4-5-20251001';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
    ),
  );

  Map<String, String> _headers(String apiKey) => {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      };

  Future<String> _send({
    required String apiKey,
    required String system,
    required String user,
    int maxTokens = 500,
  }) async {
    try {
      final resp = await _dio.post(
        _url,
        options: Options(headers: _headers(apiKey)),
        data: {
          'model': _model,
          'max_tokens': maxTokens,
          'system': system,
          'messages': [
            {'role': 'user', 'content': user},
          ],
        },
      );
      final content = resp.data['content'] as List;
      return (content.first as Map)['text'] as String? ?? '응답을 가져오지 못했습니다.';
    } on DioException catch (e) {
      debugPrint('[Claude] ${e.response?.statusCode}: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('API 키가 올바르지 않습니다. 설정에서 다시 확인해주세요.');
      }
      throw Exception('AI 연결에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  // ─── AI Coach chat ────────────────────────────────────────────────────────
  Future<String> ask({
    required String apiKey,
    required String question,
    int todayMinutes = 0,
    int weekMinutes = 0,
    double focusScore = 80.0,
    String topSubject = '없음',
    bool faceDetected = false,
    bool drowsy = false,
  }) {
    final ctx = '[공부 현황: 오늘 ${todayMinutes ~/ 60}시간 ${todayMinutes % 60}분, '
        '이번 주 ${weekMinutes ~/ 60}시간 ${weekMinutes % 60}분, '
        '집중도 ${focusScore.toInt()}점, 주요과목: $topSubject'
        '${faceDetected ? ', 얼굴 인식: 정상' : ''}'
        '${drowsy ? ', 졸음 감지: 있음' : ''}] $question';
    return _send(
      apiKey: apiKey,
      system: 'StudyVerse AI 공부 코치입니다. 한국어로 3문장 이내 맞춤형 조언을 해주세요. 격려하는 톤, 이모지 1~2개.',
      user: ctx,
    );
  }

  // ─── AI Study Plan ────────────────────────────────────────────────────────
  Future<String> generateStudyPlan({
    required String apiKey,
    required String subject,
    required String examDate,
    required int dailyHours,
    required String currentLevel,
  }) {
    return _send(
      apiKey: apiKey,
      system: '당신은 학습 계획 전문가입니다. 시험까지 일별 학습 일정을 구체적으로 작성하세요. '
          '주간 계획, 일별 목표, 주요 단원 순서를 포함. 마크다운 형식으로 답하세요.',
      user: '과목: $subject\n시험일: $examDate\n하루 공부 가능 시간: ${dailyHours}시간\n현재 수준: $currentLevel\n\n위 정보를 바탕으로 상세한 학습 계획을 세워주세요.',
      maxTokens: 1000,
    );
  }

  // ─── AI Flashcards ───────────────────────────────────────────────────────
  Future<String> generateFlashcards({
    required String apiKey,
    required String topic,
    required int count,
  }) {
    return _send(
      apiKey: apiKey,
      system: '학습용 플래시카드를 생성하는 전문가입니다. 각 카드를 "Q: [질문]\nA: [답변]" 형식으로 작성하세요. 번호를 매겨주세요.',
      user: '$topic 주제로 핵심 개념 ${count}개의 플래시카드를 만들어주세요.',
      maxTokens: 1000,
    );
  }

  // ─── AI Wrong Answer Analysis ─────────────────────────────────────────────
  Future<String> analyzeWrongAnswers({
    required String apiKey,
    required String subject,
    required List<String> wrongQuestions,
  }) {
    final qs = wrongQuestions.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
    return _send(
      apiKey: apiKey,
      system: '오답 분석 전문가입니다. 틀린 문제 유형을 분석하고 집중 학습이 필요한 영역과 구체적 개선 방법을 알려주세요.',
      user: '과목: $subject\n틀린 문제들:\n$qs\n\n이 오답들을 분석해서 취약 유형과 개선 전략을 알려주세요.',
      maxTokens: 800,
    );
  }

  // ─── AI Question Generator ────────────────────────────────────────────────
  Future<String> generateQuestions({
    required String apiKey,
    required String topic,
    required String difficulty,
    required int count,
  }) {
    return _send(
      apiKey: apiKey,
      system: '시험 문제 출제 전문가입니다. 각 문제에 번호, 문제, 보기(①②③④⑤), 정답, 해설을 포함하세요.',
      user: '$topic 주제, $difficulty 난이도로 객관식 문제 ${count}개를 출제해주세요.',
      maxTokens: 1200,
    );
  }

  // ─── Grade Simulation ─────────────────────────────────────────────────────
  Future<String> simulateGrade({
    required String apiKey,
    required String subject,
    required int totalStudyHours,
    required double avgFocusScore,
    required String targetGrade,
    required String examDate,
  }) {
    return _send(
      apiKey: apiKey,
      system: '학습 데이터 분석 전문가입니다. 현재 학습량과 집중도를 분석해 예상 등급과 목표 달성을 위한 조언을 제시하세요.',
      user: '과목: $subject\n총 공부 시간: ${totalStudyHours}시간\n평균 집중도: ${avgFocusScore.toInt()}점\n목표 등급: $targetGrade\n시험일: $examDate\n\n예상 등급을 시뮬레이션하고 목표 달성 가능성을 분석해주세요.',
      maxTokens: 600,
    );
  }

  // ─── AI Mentor (deep coaching) ────────────────────────────────────────────
  Future<String> mentorCoach({
    required String apiKey,
    required String weakness,
    required String goal,
    required int daysLeft,
  }) {
    return _send(
      apiKey: apiKey,
      system: '당신은 엄격하지만 따뜻한 AI 멘토입니다. 학생의 약점을 정확히 짚고 D-day까지 집중 코칭 계획을 세워주세요. 구체적이고 실천 가능한 조언을 해주세요.',
      user: '약점 영역: $weakness\n최종 목표: $goal\n남은 기간: D-$daysLeft\n\n집중 코칭 플랜을 작성해주세요.',
      maxTokens: 800,
    );
  }

  // ─── OCR Text Analysis ────────────────────────────────────────────────────
  Future<String> analyzeOcrText({
    required String apiKey,
    required String ocrText,
    required String task,
  }) {
    return _send(
      apiKey: apiKey,
      system: '교육 콘텐츠 분석 전문가입니다. OCR로 스캔된 텍스트를 분석하고 요청된 작업을 수행하세요.',
      user: '스캔된 텍스트:\n$ocrText\n\n요청: $task',
      maxTokens: 1000,
    );
  }

  // ─── AI Break Recommendation ──────────────────────────────────────────────
  Future<String> recommendBreak({
    required String apiKey,
    required int studiedMinutes,
    required double focusScore,
    required bool isDrowsy,
  }) {
    return _send(
      apiKey: apiKey,
      system: '집중력 관리 전문가입니다. 공부 상태를 분석해 최적의 휴식 방법을 추천하세요. 짧고 실용적으로.',
      user: '현재까지 공부한 시간: $studiedMinutes분\n집중도: ${focusScore.toInt()}점\n졸음: ${isDrowsy ? "있음" : "없음"}\n\n지금 어떻게 쉬는 게 좋을까요?',
    );
  }

  // ─── Voice Question Answer ────────────────────────────────────────────────
  Future<String> answerVoiceQuestion({
    required String apiKey,
    required String question,
    required String subject,
  }) {
    return _send(
      apiKey: apiKey,
      system: '친절한 AI 선생님입니다. 학생의 질문에 쉽고 명확하게 답변하세요. 핵심을 먼저, 예시로 설명하세요.',
      user: '과목: $subject\n질문: $question',
      maxTokens: 600,
    );
  }
}
