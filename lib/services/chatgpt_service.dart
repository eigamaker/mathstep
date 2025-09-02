import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/solution.dart';
import '../config/api_config.dart';

class ChatGptService {

  Future<Solution> generateSolution(String latexExpression) async {
    // API設定が正しく読み込まれているかチェック
    if (!ApiConfig.isConfigured) {
      throw Exception('OpenAI API key is not configured. Please check your .env file.');
    }
    
    final systemPrompt = '''
あなたは受験数学の専門家です。与えられた数式について、以下の形式で詳しく解説してください：

1. ステップバイステップの解法
2. 別解がある場合はそれも提示
3. 検算・定義域チェック
4. よくある間違いポイント

回答は以下のJSON形式で返してください：
{
  "steps": [
    {
      "id": "step1",
      "title": "ステップ1のタイトル",
      "description": "詳細な説明",
      "latexExpression": "\\LaTeX式（必要に応じて）"
    }
  ],
  "alternativeSolutions": [
    {
      "id": "alt1",
      "title": "別解のタイトル",
      "steps": [...]
    }
  ],
  "verification": {
    "domainCheck": "定義域の確認",
    "verification": "検算結果",
    "commonMistakes": "よくある間違い"
  }
}
''';

    final userPrompt = '''
以下の数式について解説してください：

\\[ $latexExpression \\]

受験生向けに分かりやすく、ステップごとに詳しく説明してください。
''';

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.openaiApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.openaiApiKey}',
        },
        body: jsonEncode({
          'model': ApiConfig.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': ApiConfig.temperature,
          'max_tokens': ApiConfig.maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // JSONレスポンスをパース
        return _parseSolutionResponse(content);
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      // API呼び出しに失敗した場合は、モックデータを返す
      return _createMockSolution(latexExpression);
    }
  }

  Solution _parseSolutionResponse(String content) {
    try {
      // JSON部分を抽出
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = content.substring(jsonStart, jsonEnd);
        final jsonData = jsonDecode(jsonString);
        
        return Solution(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          mathExpressionId: '',
          steps: (jsonData['steps'] as List).map((step) => SolutionStep(
            id: step['id'],
            title: step['title'],
            description: step['description'],
            latexExpression: step['latexExpression'],
          )).toList(),
          alternativeSolutions: jsonData['alternativeSolutions'] != null
              ? (jsonData['alternativeSolutions'] as List).map((alt) => AlternativeSolution(
                  id: alt['id'],
                  title: alt['title'],
                  steps: (alt['steps'] as List).map((step) => SolutionStep(
                    id: step['id'],
                    title: step['title'],
                    description: step['description'],
                    latexExpression: step['latexExpression'],
                  )).toList(),
                )).toList()
              : null,
          verification: jsonData['verification'] != null
              ? Verification(
                  domainCheck: jsonData['verification']['domainCheck'],
                  verification: jsonData['verification']['verification'],
                  commonMistakes: jsonData['verification']['commonMistakes'],
                )
              : null,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      // JSON解析に失敗した場合
    }
    
    // フォールバック: モックデータを返す
    return _createMockSolution('');
  }

  Solution _createMockSolution(String latexExpression) {
    return Solution(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mathExpressionId: '',
      steps: [
        SolutionStep(
          id: 'step1',
          title: '問題の理解',
          description: '与えられた数式を分析し、解くべき問題を明確にします。',
        ),
        SolutionStep(
          id: 'step2',
          title: '解法の適用',
          description: '適切な数学的手法を用いて問題を解きます。',
        ),
        SolutionStep(
          id: 'step3',
          title: '答えの確認',
          description: '得られた答えが正しいかどうかを確認します。',
        ),
      ],
      alternativeSolutions: [
        AlternativeSolution(
          id: 'alt1',
          title: '別解',
          steps: [
            SolutionStep(
              id: 'alt_step1',
              title: '別のアプローチ',
              description: '異なる方法で問題を解きます。',
            ),
          ],
        ),
      ],
      verification: Verification(
        domainCheck: '定義域を確認してください。',
        verification: '答えを元の式に代入して検算してください。',
        commonMistakes: '符号の間違いや計算ミスに注意してください。',
      ),
      timestamp: DateTime.now(),
    );
  }
}
