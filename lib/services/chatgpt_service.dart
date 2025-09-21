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
あなたは高校数学の専門講師です。与えられた数式を分析して、以下の手順で回答してください：

1. 数式から数学の問題を推測し、問題文として提示する
2. その問題を解くための段階的な解法を提供する
3. 代替解法がある場合は提示する
4. 検証と定義域の確認を行う
5. よくある間違いや注意点を指摘する

回答は以下のJSON形式で返してください：
{
  "problemStatement": "推測した数学の問題文（例：f(x) = 2^{x+1} - √(2x) の最小値を求めよ。また、そのときのxの値を求めよ。）",
  "steps": [
    {
      "id": "step1",
      "title": "ステップのタイトル",
      "description": "詳細な説明",
      "latexExpression": "必要に応じてLaTeX式"
    }
  ],
  "alternativeSolutions": [
    {
      "id": "alt1",
      "title": "代替解法",
      "steps": [ ... ]
    }
  ],
  "verification": {
    "domainCheck": "定義域の確認",
    "verification": "検証手順",
    "commonMistakes": "よくある間違い"
  }
}

数式の種類に応じて適切な問題を推測してください：
- 関数式 → 最大値・最小値、極値、グラフの性質
- 方程式 → 解の求め方、解の個数、実数解の条件
- 不等式 → 解の範囲、成立条件
- 三角関数 → 周期、振幅、位相、最大値・最小値
- 指数・対数 → 増減、漸近線、交点
- 積分 → 面積、体積、定積分の値
- 微分 → 接線、法線、極値、変曲点
''';

  String _buildUserPrompt(String latexExpression) {
    return '''以下の数式を分析して、高校生向けに数学の問題として提示し、解法を説明してください。
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
        problemStatement: _safeStringCast(jsonMap['problemStatement']),
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
