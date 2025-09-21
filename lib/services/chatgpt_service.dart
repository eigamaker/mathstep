import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../constants/app_constants.dart';
import '../models/solution.dart';
import 'json_parser.dart';
import 'prompt_generator.dart';

class ChatGptService {
  ChatGptService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<Solution> generateSolution(String latexExpression, [String? condition]) async {
    if (!ApiConfig.isConfigured) {
      throw Exception(AppConstants.apiKeyNotConfiguredError);
    }

    final client = _client ?? http.Client();
    try {
      final requestBody = {
        'model': ApiConfig.model,
        'messages': [
          {'role': 'system', 'content': PromptGenerator.systemPrompt},
          {'role': 'user', 'content': PromptGenerator.buildUserPrompt(latexExpression, condition)},
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
          '${AppConstants.apiRequestFailedError} ${response.statusCode}: ${response.body}',
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
        throw const FormatException(AppConstants.emptyResponseError);
      }

      final solution = JsonParser.parseSolutionResponse(content);
      if (solution == null) {
        throw Exception(AppConstants.jsonParseError);
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

}
