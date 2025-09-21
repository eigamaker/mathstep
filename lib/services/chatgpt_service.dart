import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/solution.dart';

class ChatGptService {
  ChatGptService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<Solution> generateSolution(String latexExpression, [String? condition]) async {
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
          {'role': 'user', 'content': _buildUserPrompt(latexExpression, condition)},
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
あなたは高校数学の専門講師です。高校生が理解しやすいように、以下の方針で回答してください：

【解法の方針】
1. 必ず導関数を使った解法をメインにする
2. 変数変換（t、uなど）は絶対に使わない
3. 元の関数f(x)を直接扱う
4. 計算過程を丁寧に説明する
5. 高校生が知っている公式のみを使用する

【回答形式】
以下のJSON形式で返してください：
{
  "problemStatement": "数学の問題文",
  "steps": [
    {
      "id": "step1",
      "title": "ステップのタイトル",
      "description": "高校生向けの分かりやすい説明",
      "latexExpression": "シンプルなLaTeX式"
    }
  ],
  "alternativeSolutions": [
    {
      "id": "alt1",
      "title": "別の解法",
      "steps": [ ... ]
    }
  ],
  "verification": {
    "domainCheck": "定義域の確認",
    "verification": "検証手順",
    "commonMistakes": "よくある間違い"
  }
}

【LaTeXの書き方】
- バックスラッシュは二重エスケープ（\\）してください
- 複雑な記号は避け、基本的な記号のみ使用
- 例：\\frac{1}{2}、\\sqrt{x}、x^2

【解法のルール】
- 絶対に変数変換（t=...、u=...）を使わない
- f(x)の導関数f'(x)を求めて解く
- 計算過程を省略せず、すべて示す
- 高校生が理解できるレベルで説明する

【禁止事項】
- 変数変換（t、u、g(t)、h(u)など）
- 大学レベルの高度な手法
- 複雑すぎるLaTeX記法
- 説明の省略
''';

  String _buildUserPrompt(String latexExpression, [String? condition]) {
    if (condition != null && condition.isNotEmpty) {
      return '''以下の数式を分析して、高校生向けに数学の問題として提示し、解法を説明してください。

数式：
\\[ $latexExpression \\]

条件・求める解：
$condition

上記の条件を考慮して、適切な解法を提供してください。
''';
    } else {
      return '''以下の数式を分析して、高校生向けに数学の問題として提示し、解法を説明してください。
\\[ $latexExpression \\]
''';
    }
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

      Map<String, dynamic> jsonMap;
      try {
        jsonMap = jsonDecode(cleanedJsonString) as Map<String, dynamic>;
        debugPrint('Parsed JSON Map: $jsonMap');
      } catch (e) {
        debugPrint('Failed to parse solution response: $e');
        debugPrint('Original JSON: $jsonString');
        debugPrint('Cleaned JSON: $cleanedJsonString');
        throw Exception('APIからの応答を解析できませんでした。JSON形式が正しくありません。');
      }

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
    // ChatGPTが既に正しくエスケープしている場合は、そのまま使用
    // 問題のあるエスケープシーケンスのみを修正
    
    String cleaned = jsonString;
    
    // 無効なエスケープシーケンスを修正（JSONで有効でないもの）
    // ただし、LaTeXコマンドは既に正しくエスケープされているので触らない
    
    // 例外的に修正が必要なケースのみ処理
    // 3つ以上の連続するバックスラッシュを2つに統一
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\\{3,}'),
      (match) => '\\\\',
    );
    
    return cleaned;
  }
}
