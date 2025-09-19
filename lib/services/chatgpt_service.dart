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
      debugPrint('OpenAI API key is not configured. Returning mock data.');
      return _createMockSolution(latexExpression);
    }

    final client = _client ?? http.Client();
    try {
      final response = await client.post(
        Uri.parse(ApiConfig.openaiApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.openaiApiKey}',
        },
        body: jsonEncode({
          'model': ApiConfig.model,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': _buildUserPrompt(latexExpression)},
          ],
          'temperature': ApiConfig.temperature,
          'max_tokens': ApiConfig.maxTokens,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'API request failed with status ${response.statusCode}',
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

      return _parseSolutionResponse(content) ??
          _createMockSolution(latexExpression);
    } catch (error, stackTrace) {
      debugPrint('ChatGptService error: $error\n$stackTrace');
      return _createMockSolution(latexExpression);
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
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      return Solution(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mathExpressionId: '',
        steps: (jsonMap['steps'] as List<dynamic>? ?? [])
            .map(
              (step) => SolutionStep(
                id: step['id'] as String,
                title: step['title'] as String,
                description: step['description'] as String,
                latexExpression: step['latexExpression'] as String?,
              ),
            )
            .toList(),
        alternativeSolutions:
            (jsonMap['alternativeSolutions'] as List<dynamic>?)
                ?.map(
                  (alt) => AlternativeSolution(
                    id: alt['id'] as String,
                    title: alt['title'] as String,
                    steps: (alt['steps'] as List<dynamic>)
                        .map(
                          (step) => SolutionStep(
                            id: step['id'] as String,
                            title: step['title'] as String,
                            description: step['description'] as String,
                            latexExpression: step['latexExpression'] as String?,
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
        verification: jsonMap['verification'] != null
            ? Verification(
                domainCheck: jsonMap['verification']['domainCheck'] as String?,
                verification:
                    jsonMap['verification']['verification'] as String?,
                commonMistakes:
                    jsonMap['verification']['commonMistakes'] as String?,
              )
            : null,
        timestamp: DateTime.now(),
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to parse solution response: $error\n$stackTrace');
      return null;
    }
  }

  Solution _createMockSolution(String latexExpression) {
    return Solution(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mathExpressionId: '',
      steps: const [
        SolutionStep(
          id: 'step1',
          title: 'Understand the problem',
          description:
              'Rephrase the given expression and identify what must be solved.',
        ),
        SolutionStep(
          id: 'step2',
          title: 'Apply a strategy',
          description:
              'Select a suitable technique and show the intermediate reasoning.',
        ),
        SolutionStep(
          id: 'step3',
          title: 'Verify the answer',
          description:
              'Substitute the result back into the original equation to confirm it.',
        ),
      ],
      alternativeSolutions: const [
        AlternativeSolution(
          id: 'alt1',
          title: 'Alternative method',
          steps: [
            SolutionStep(
              id: 'alt_step1',
              title: 'Different viewpoint',
              description:
                  'Present another approach that reaches the same conclusion.',
            ),
          ],
        ),
      ],
      verification: const Verification(
        domainCheck:
            'Confirm the domain restrictions before accepting the answer.',
        verification: 'Re-evaluate the expression using the obtained solution.',
        commonMistakes:
            'Watch out for sign errors and skipped algebraic steps.',
      ),
      timestamp: DateTime.now(),
    );
  }
}
