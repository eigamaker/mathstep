import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/solution.dart';
import '../localization/app_language.dart';
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
    String latexExpression, {
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
      final requestBody = {
        'model': ApiConfig.model,
        'messages': [
          {
            'role': 'system',
            'content': PromptGenerator.buildSystemPrompt(language),
          },
          {
            'role': 'user',
            'content': PromptGenerator.buildUserPrompt(
              latexExpression,
              condition: condition,
              language: language,
            ),
          },
        ],
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
        throw ChatGptException(
          ChatGptErrorType.apiRequestFailed,
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
        throw const ChatGptException(
          ChatGptErrorType.emptyResponse,
          'Empty response from API',
        );
      }

      final solution = JsonParser.parseSolutionResponse(content);
      if (solution == null) {
        throw const ChatGptException(
          ChatGptErrorType.jsonParse,
          'Failed to parse solution JSON',
        );
      }
      return solution;
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
}
