import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/solution.dart';
import '../localization/app_language.dart';
import '../utils/asciimath_converter.dart';
import 'json_parser.dart';
import 'prompt_generator.dart';

enum ChatGptErrorType {
  apiKeyMissing,
  apiRequestFailed,
  emptyResponse,
  jsonParse,
}

class ChatGptException implements Exception {
  const ChatGptException(this.type, this.message);

  final ChatGptErrorType type;
  final String message;

  @override
  String toString() => message;
}

class ChatGptService {
  ChatGptService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<Solution> generateSolution(
    String asciiMathExpression, {
    String? condition,
    required AppLanguage language,
  }) async {
    if (!ApiConfig.isConfigured) {
      throw const ChatGptException(
        ChatGptErrorType.apiKeyMissing,
        'OpenAI API key is not configured. Set OPENAI_API_KEY in the .env file.',
      );
    }

    final client = _client ?? http.Client();
    try {
      final response = await _makeApiRequest(
        asciiMathExpression,
        condition: condition,
        language: language,
        client: client,
      );

      final content = _extractContentFromResponse(response);
      final solution = _parseSolutionFromContent(content);
      
      // AsciiMath応答を正規化
      final normalizedSolution = _normalizeSolution(solution);
      
      debugPrint('Solution parsed and normalized successfully: ${normalizedSolution.steps.length} steps');
      return normalizedSolution;
    } catch (error, stackTrace) {
      debugPrint('ChatGptService error: $error\n$stackTrace');
      if (error is ChatGptException) {
        rethrow;
      }
      throw ChatGptException(
        ChatGptErrorType.apiRequestFailed,
        error.toString(),
      );
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  /// APIリクエストを実行する
  Future<http.Response> _makeApiRequest(
    String asciiMathExpression, {
    String? condition,
    required AppLanguage language,
    required http.Client client,
  }) async {
    final requestBody = _buildRequestBody(
      asciiMathExpression,
      condition: condition,
      language: language,
    );

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
      throw ChatGptException(
        ChatGptErrorType.apiRequestFailed,
        'API request failed with status ${response.statusCode}: ${response.body}',
      );
    }

    return response;
  }

  /// リクエストボディを構築する
  Map<String, dynamic> _buildRequestBody(
    String asciiMathExpression, {
    String? condition,
    required AppLanguage language,
  }) {
    return {
      'model': ApiConfig.model,
      'messages': [
        {
          'role': 'system',
          'content': PromptGenerator.buildSystemPrompt(language),
        },
        {
          'role': 'user',
          'content': PromptGenerator.buildUserPrompt(
            asciiMathExpression,
            condition: condition,
            language: language,
            outputMode: 'json',
          ),
        },
      ],
    };
  }

  /// レスポンスからコンテンツを抽出する
  String _extractContentFromResponse(http.Response response) {
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('API Response payload: $payload');
    
    final choices = payload['choices'] as List<dynamic>?;
    debugPrint('API Response choices: $choices');
    
    final firstChoice = (choices != null && choices.isNotEmpty)
        ? choices.first as Map<String, dynamic>
        : null;
    debugPrint('API Response firstChoice: $firstChoice');
    
    final message = firstChoice?['message'] as Map<String, dynamic>?;
    debugPrint('API Response message: $message');
    
    final content = message?['content'] as String?;
    debugPrint('API Response content: $content');

    if (content == null || content.isEmpty) {
      debugPrint('Empty content received from API');
      throw const ChatGptException(
        ChatGptErrorType.emptyResponse,
        'Empty response from API',
      );
    }

    return content;
  }

  /// コンテンツからソリューションを解析する
  Solution _parseSolutionFromContent(String content) {
    debugPrint('Parsing solution from content...');
    debugPrint('Content length: ${content.length}');
    debugPrint('Content preview: ${content.length > 200 ? "${content.substring(0, 200)}..." : content}');
    
    final solution = JsonParser.parseSolutionResponse(content);
    if (solution == null) {
      debugPrint('Failed to parse solution JSON from content: $content');
      throw const ChatGptException(
        ChatGptErrorType.jsonParse,
        'Failed to parse solution JSON',
      );
    }
    
    debugPrint('Solution parsed successfully:');
    debugPrint('- Problem statement: ${solution.problemStatement}');
    debugPrint('- Steps count: ${solution.steps.length}');
    debugPrint('- Similar problems count: ${solution.similarProblems?.length ?? 0}');
    
    return solution;
  }

  /// ソリューションのAsciiMath表現を正規化
  Solution _normalizeSolution(Solution solution) {
    final normalizedSteps = solution.steps.map((step) {
      final normalizedExpression = step.latexExpression != null
          ? AsciiMathConverter.normalizeChatGptResponse(step.latexExpression!)
          : null;
      
      return SolutionStep(
        id: step.id,
        title: step.title,
        description: step.description,
        latexExpression: normalizedExpression,
      );
    }).toList();

    final normalizedSimilarProblems = solution.similarProblems?.map((similar) {
      final normalizedSimilarSteps = similar.solutionSteps.map((step) {
        final normalizedExpression = step.latexExpression != null
            ? AsciiMathConverter.normalizeChatGptResponse(step.latexExpression!)
            : null;
        
        return SolutionStep(
          id: step.id,
          title: step.title,
          description: step.description,
          latexExpression: normalizedExpression,
        );
      }).toList();

      return SimilarProblem(
        id: similar.id,
        title: similar.title,
        description: similar.description,
        problemExpression: similar.problemExpression,
        solutionSteps: normalizedSimilarSteps,
      );
    }).toList();

    return Solution(
      id: solution.id,
      mathExpressionId: solution.mathExpressionId,
      problemStatement: solution.problemStatement != null
          ? AsciiMathConverter.normalizeChatGptResponse(solution.problemStatement!)
          : null,
      steps: normalizedSteps,
      similarProblems: normalizedSimilarProblems,
      timestamp: solution.timestamp,
    );
  }
}
