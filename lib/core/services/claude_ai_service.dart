import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ClaudeAiService {
  static const _url = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-haiku-4-5-20251001';
  static const _system =
      '당신은 StudyVerse 앱의 AI 공부 코치입니다. '
      '사용자 공부 데이터를 분석해 한국어로 맞춤형 조언을 해주세요. '
      '답변은 3문장 이내, 격려하는 톤으로 실용적으로 작성하세요. '
      '이모지를 1~2개 사용해 친근하게 표현해주세요.';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<String> ask({
    required String apiKey,
    required String question,
    int todayMinutes = 0,
    int weekMinutes = 0,
    double focusScore = 80.0,
    String topSubject = '없음',
    bool faceDetected = false,
    bool drowsy = false,
  }) async {
    final context =
        '[공부 현황: 오늘 ${todayMinutes ~/ 60}시간 ${todayMinutes % 60}분, '
        '이번 주 ${weekMinutes ~/ 60}시간 ${weekMinutes % 60}분, '
        '집중도 ${focusScore.toInt()}점, 주요과목: $topSubject'
        '${faceDetected ? ', 얼굴 인식: 정상' : ''}'
        '${drowsy ? ', 졸음 감지: 있음' : ''}] '
        '$question';

    try {
      final resp = await _dio.post(
        _url,
        options: Options(headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        }),
        data: {
          'model': _model,
          'max_tokens': 400,
          'system': _system,
          'messages': [
            {'role': 'user', 'content': context},
          ],
        },
      );
      final content = resp.data['content'] as List;
      return (content.first as Map)['text'] as String? ??
          '응답을 가져오지 못했습니다.';
    } on DioException catch (e) {
      debugPrint('[Claude] ${e.response?.statusCode}: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('API 키가 올바르지 않습니다. 설정에서 다시 확인해주세요.');
      }
      throw Exception('AI 연결에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }
}
