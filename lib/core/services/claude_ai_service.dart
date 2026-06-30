import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// AI service backed by Google's Gemini API (Generative Language API).
///
/// Get a free API key at https://aistudio.google.com/app/apikey and enter it
/// once on the AI Coach screen — all AI tools then use it automatically.
/// (Class name kept for compatibility with existing call sites.)
class ClaudeAiService {
  static const _model = 'gemini-flash-latest';
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
    ),
  );

  Future<String> _send({
    required String apiKey,
    required String system,
    required String user,
    int maxTokens = 500,
  }) async {
    try {
      // Conversation turns; we append the model's partial output + a
      // "continue" turn whenever the answer is cut off (finishReason MAX_TOKENS)
      // so the user never sees a sentence that stops mid-way.
      final contents = <Map<String, dynamic>>[
        {
          'parts': [
            {'text': user},
          ],
        },
      ];
      final buffer = StringBuffer();
      const maxRounds = 4;
      for (var round = 0; round < maxRounds; round++) {
        final resp = await _dio.post(
          '$_baseUrl/$_model:generateContent',
          options: Options(headers: {
            'content-type': 'application/json',
            'X-goog-api-key': apiKey,
          }),
          data: {
            'system_instruction': {
              'parts': [
                {'text': system},
              ],
            },
            'contents': contents,
            // Disable reasoning so the full answer fits the output budget
            // (otherwise gemini-flash spends tokens on thinking and truncates).
            'generationConfig': {
              'maxOutputTokens': maxTokens.clamp(2048, 8192),
              'temperature': 0.7,
              'thinkingConfig': {'thinkingBudget': 0},
            },
          },
        );
        final candidates = resp.data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) break;
        final first = candidates.first as Map;
        final parts = first['content']?['parts'] as List?;
        final chunk = (parts ?? [])
            .map((p) => (p as Map)['text'])
            .whereType<String>()
            .join('\n');
        if (chunk.isNotEmpty) buffer.write(chunk);

        final finish = first['finishReason'] as String?;
        if (finish != 'MAX_TOKENS') break; // complete answer
        // Ask the model to continue exactly where it left off.
        contents.add({
          'role': 'model',
          'parts': [
            {'text': chunk},
          ],
        });
        contents.add({
          'role': 'user',
          'parts': [
            {'text': '끊긴 부분에서 이어서 계속 작성해줘. 인사말이나 반복 없이 바로 이어서.'},
          ],
        });
      }
      final text = buffer.toString().trim();
      return text.isEmpty ? '응답을 가져오지 못했습니다.' : text;
    } on DioException catch (e) {
      debugPrint('[Gemini] ${e.response?.statusCode}: ${e.message}');
      final code = e.response?.statusCode;
      if (code == 400 || code == 401 || code == 403) {
        throw Exception('API 키가 올바르지 않습니다. 설정에서 다시 확인해주세요.');
      }
      throw Exception('AI 연결에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /// Vision: analyse an image directly with Gemini (real OCR + understanding).
  Future<String> analyzeImage({
    required String apiKey,
    required List<int> imageBytes,
    required String task,
    String detail = '',
    String mimeType = 'image/jpeg',
  }) async {
    final prompt = '이미지(프린트물·교재·필기 등)를 정확히 읽고 다음 작업을 한국어로 수행하세요.\n'
        '작업: $task'
        '${detail.trim().isEmpty ? '' : '\n추가 요청사항: ${detail.trim()}'}';
    try {
      final resp = await _dio.post(
        '$_baseUrl/$_model:generateContent',
        options: Options(headers: {
          'content-type': 'application/json',
          'X-goog-api-key': apiKey,
        }),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': mimeType,
                    'data': base64Encode(imageBytes),
                  },
                },
              ],
            },
          ],
          'generationConfig': {
            'maxOutputTokens': 2048,
            'temperature': 0.4,
            'thinkingConfig': {'thinkingBudget': 0},
          },
        },
      );
      final candidates = resp.data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        return '이미지를 분석하지 못했습니다.';
      }
      final parts = (candidates.first as Map)['content']?['parts'] as List?;
      final text = (parts ?? [])
          .map((p) => (p as Map)['text'])
          .whereType<String>()
          .join('\n')
          .trim();
      return text.isEmpty ? '이미지를 분석하지 못했습니다.' : text;
    } on DioException catch (e) {
      debugPrint('[Gemini-vision] ${e.response?.statusCode}: ${e.message}');
      final code = e.response?.statusCode;
      if (code == 400 || code == 401 || code == 403) {
        throw Exception('API 키가 올바르지 않습니다. 설정에서 다시 확인해주세요.');
      }
      throw Exception('이미지 분석에 실패했습니다. 잠시 후 다시 시도해주세요.');
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
    String detail = '',
  }) {
    return _send(
      apiKey: apiKey,
      system: '당신은 학습 계획 전문가입니다. 시험까지 일별 학습 일정을 구체적으로 작성하세요. '
          '주간 계획, 일별 목표, 주요 단원 순서를 포함. 마크다운 형식으로 답하세요.',
      user: '과목: $subject\n시험일: $examDate\n하루 공부 가능 시간: ${dailyHours}시간\n현재 수준: $currentLevel'
          '${detail.trim().isEmpty ? '' : '\n추가 요청사항: ${detail.trim()}'}\n\n위 정보를 바탕으로 상세한 학습 계획을 세워주세요.',
      maxTokens: 2048,
    );
  }

  // ─── AI Flashcards ───────────────────────────────────────────────────────
  Future<String> generateFlashcards({
    required String apiKey,
    required String topic,
    required int count,
    String difficulty = '보통',
    String detail = '',
  }) {
    return _send(
      apiKey: apiKey,
      system: '학습용 플래시카드를 생성하는 전문가입니다. 각 카드를 "Q: [질문]\nA: [답변]" 형식으로 작성하세요. 번호를 매겨주세요. '
          '난이도에 맞춰 질문의 깊이와 답변의 상세함을 조절하세요. '
          '(쉬움: 기초 용어·정의 위주, 보통: 개념 이해·적용, 어려움: 심화·응용·함정 포인트 포함)',
      user: '$topic 주제로 난이도 "$difficulty"의 핵심 개념 ${count}개 플래시카드를 만들어주세요.'
          '${detail.trim().isEmpty ? '' : '\n추가 요청사항: ${detail.trim()}'}',
      maxTokens: 2048,
    );
  }

  // ─── AI English Vocabulary Test ───────────────────────────────────────────
  /// Returns one quiz item per line in the strict format:
  ///   word | 정답 한글뜻 | 오답1 ; 오답2 ; 오답3
  Future<String> generateVocabTest({
    required String apiKey,
    required String level,
    required int count,
  }) {
    return _send(
      apiKey: apiKey,
      system: '영어 단어 시험 출제기입니다. 반드시 아래 형식만, 한 줄에 하나씩, 다른 말 없이 출력하세요.\n'
          '형식: 영단어 | 정답(한글 뜻) | 오답1 ; 오답2 ; 오답3\n'
          '- 오답은 정답과 헷갈릴 만한 그럴듯한 한글 뜻 3개\n'
          '- 마크다운·번호·설명 금지, 줄마다 형식만',
      user: '$level 수준의 영어 단어 $count개로 4지선다 단어 시험을 만들어주세요.',
      maxTokens: 2048,
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
    String detail = '',
  }) {
    return _send(
      apiKey: apiKey,
      system: '학습 데이터 분석 전문가입니다. 현재 학습량과 집중도를 분석해 예상 등급과 목표 달성을 위한 조언을 제시하세요.',
      user: '과목: $subject\n총 공부 시간: ${totalStudyHours}시간\n평균 집중도: ${avgFocusScore.toInt()}점\n목표 등급: $targetGrade\n시험일: $examDate'
          '${detail.trim().isEmpty ? '' : '\n추가 요청사항: ${detail.trim()}'}\n\n예상 등급을 시뮬레이션하고 목표 달성 가능성을 분석해주세요.',
      maxTokens: 2048,
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
