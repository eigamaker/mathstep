import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/solution.dart';

class ChatGptService {
  ChatGptService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<Solution> generateSolution(String latexExpression) async {
    if (!ApiConfig.isConfigured) {
      throw Exception(
        'OpenAI APIキーが設定されていません。.envファイルにOPENAI_API_KEYを設定してください。',
      );
    }

    final client = _client ?? http.Client();
    try {
      final requestBody = {
        'model': ApiConfig.model,
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': _buildUserPrompt(latexExpression)},
        ],
        // temperatureとmax_tokensパラメータを削除（モデルによって異なるため）
      };

      debugPrint('API Request URL: ${ApiConfig.openaiApiUrl}');
      debugPrint('API Request Model: ${ApiConfig.model}');
      debugPrint('API Request Body: ${jsonEncode(requestBody)}');

      final response = await client.post(
        Uri.parse(ApiConfig.openaiApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.openaiApiKey}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        debugPrint('API Error Response: ${response.body}');
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = payload['choices'] as List<dynamic>?;
      final firstChoice = (choices != null && choices.isNotEmpty)
          ? choices.first as Map<String, dynamic>
          : null;
      final message = firstChoice?['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String?;

      if (content == null || content.isEmpty) {
        throw const FormatException('Empty response from API');
      }

      final solution = _parseSolutionResponse(content);
      if (solution == null) {
        throw Exception('APIからの応答を解析できませんでした。');
      }
      return solution;
    } catch (error, stackTrace) {
      debugPrint('ChatGptService error: $error\n$stackTrace');
      rethrow; // エラーを再スローして、呼び出し元で処理させる
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  static const _systemPrompt = '''
You are an expert math tutor for exam preparation. Provide step-by-step explanations covering:
1. Detailed reasoning for each step
2. Alternative approaches when they exist
3. Verification and domain checks
4. Common pitfalls and reminders

Return the answer in the following JSON shape:
{
  "steps": [
    {
      "id": "step1",
      "title": "Step title",
      "description": "Explanation",
      "latexExpression": "\\LaTeX expression if needed"
    }
  ],
  "alternativeSolutions": [
    {
      "id": "alt1",
      "title": "Alternative approach",
      "steps": [ ... ]
    }
  ],
  "verification": {
    "domainCheck": "Domain checks",
    "verification": "Verification steps",
    "commonMistakes": "Typical mistakes"
  }
}
''';

  String _buildUserPrompt(String latexExpression) {
    return '''Explain the following expression for high-school students.
\\[ $latexExpression \\]
''';
  }

  Solution? _parseSolutionResponse(String content) {
    try {
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start == -1 || end <= start) {
        return null;
      }

      final jsonString = content.substring(start, end + 1);
      debugPrint('Extracted JSON: $jsonString');

      // LaTeX式のエスケープ文字を処理してからJSON解析
      final cleanedJsonString = _cleanJsonString(jsonString);
      debugPrint('Cleaned JSON: $cleanedJsonString');

      final jsonMap = jsonDecode(cleanedJsonString) as Map<String, dynamic>;
      debugPrint('Parsed JSON Map: $jsonMap');

      return Solution(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mathExpressionId: '',
        steps: (jsonMap['steps'] as List<dynamic>? ?? [])
            .map(
              (step) => SolutionStep(
                id: _safeStringCast(step['id']) ?? 'unknown',
                title: _safeStringCast(step['title']) ?? 'Untitled',
                description:
                    _safeStringCast(step['description']) ?? 'No description',
                latexExpression: _safeStringCast(step['latexExpression']),
              ),
            )
            .toList(),
        alternativeSolutions:
            (jsonMap['alternativeSolutions'] as List<dynamic>?)
                ?.map(
                  (alt) => AlternativeSolution(
                    id: _safeStringCast(alt['id']) ?? 'unknown',
                    title: _safeStringCast(alt['title']) ?? 'Untitled',
                    steps: (alt['steps'] as List<dynamic>)
                        .map(
                          (step) => SolutionStep(
                            id: _safeStringCast(step['id']) ?? 'unknown',
                            title: _safeStringCast(step['title']) ?? 'Untitled',
                            description:
                                _safeStringCast(step['description']) ??
                                'No description',
                            latexExpression: _safeStringCast(
                              step['latexExpression'],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
        verification: jsonMap['verification'] != null
            ? Verification(
                domainCheck: _safeStringCast(
                  jsonMap['verification']['domainCheck'],
                ),
                verification: _safeStringCast(
                  jsonMap['verification']['verification'],
                ),
                commonMistakes: _safeStringCast(
                  jsonMap['verification']['commonMistakes'],
                ),
              )
            : null,
        timestamp: DateTime.now(),
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to parse solution response: $error\n$stackTrace');
      return null;
    }
  }

  String? _safeStringCast(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List) return value.join(', ');
    if (value is Map) return value.toString();
    return value.toString();
  }

  String _cleanJsonString(String jsonString) {
    final buffer = StringBuffer();
    var index = 0;

    while (index < jsonString.length) {
      final current = jsonString[index];
      if (current == r'\') {
        if (index + 1 < jsonString.length) {
          final next = jsonString[index + 1];
          const allowedEscapes = '"\\/bfnrtu';
          if (!allowedEscapes.contains(next)) {
            buffer.write('\\');
            buffer.write(next);
            index += 2;
            continue;
          }
        }
      }

      buffer.write(current);
      index += 1;
    }

    return buffer.toString();
  }
}
