import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../models/solution.dart';

/// Utility methods for parsing JSON responses returned by the solver backend.
class JsonParser {
  /// Parses a solution response string and returns a [Solution].
  static Solution? parseSolutionResponse(String content) {
    try {
      final jsonString = _extractJsonString(content);
      if (jsonString == null) {
        debugPrint('JsonParser: Failed to locate JSON payload in response.');
        return null;
      }

      final jsonMap = _parseJsonMap(jsonString);
      return _createSolutionFromJson(jsonMap);
    } catch (error, stackTrace) {
      debugPrint('JsonParser: Failed to parse solution response: $error\n$stackTrace');
      return null;
    }
  }

  /// Extracts the JSON payload from a raw response string.
  static String? _extractJsonString(String content) {
    final start = content.indexOf('{');
    final end = content.lastIndexOf('}');
    if (start == -1 || end <= start) {
      return null;
    }
    return content.substring(start, end + 1);
  }

  /// Decodes a JSON string to a map.
  static Map<String, dynamic> _parseJsonMap(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      return decoded as Map<String, dynamic>;
    } catch (error) {
      debugPrint('JsonParser: Failed to decode JSON: $error');
      debugPrint('JsonParser: JSON content: $jsonString');
      throw const FormatException('invalid_json_format');
    }
  }

  /// Builds a [Solution] from a decoded JSON map.
  static Solution _createSolutionFromJson(Map<String, dynamic> jsonMap) {
    return Solution(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mathExpressionId: '',
      problemStatement: _safeStringCast(jsonMap['problemStatement']),
      steps: _parseSolutionSteps(jsonMap['steps']),
      similarProblems: _parseSimilarProblems(jsonMap['similarProblems']),
      timestamp: DateTime.now(),
    );
  }

  /// Parses the list of solution steps.
  static List<SolutionStep> _parseSolutionSteps(dynamic stepsData) {
    if (stepsData is! List) {
      debugPrint('JsonParser: stepsData is not a List: $stepsData');
      return [];
    }

    debugPrint('JsonParser: Parsing ${stepsData.length} steps');
    for (int i = 0; i < stepsData.length; i++) {
      debugPrint('JsonParser: Step $i: ${stepsData[i]}');
    }

    final steps = stepsData
        .map(
          (step) => SolutionStep(
            id: _safeStringCast(step['id']) ?? AppConstants.unknownId,
            title: _safeStringCast(step['title'])?.trim() ?? '',
            description: _safeStringCast(step['description'])?.trim() ?? '',
            latexExpression: _safeStringCast(step['latexExpression']),
          ),
        )
        .toList();

    debugPrint('JsonParser: Parsed ${steps.length} steps successfully');
    for (int i = 0; i < steps.length; i++) {
      debugPrint('JsonParser: Parsed step $i: id=${steps[i].id}, title="${steps[i].title}", description="${steps[i].description}"');
    }

    return steps;
  }

  /// Parses any similar problems provided by the API.
  static List<SimilarProblem>? _parseSimilarProblems(dynamic similarData) {
    if (similarData is! List) return null;

    return similarData
        .map(
          (similar) => SimilarProblem(
            id: _safeStringCast(similar['id']) ?? AppConstants.unknownId,
            title: _safeStringCast(similar['title'])?.trim() ?? '',
            description: _safeStringCast(similar['description'])?.trim() ?? '',
            problemExpression: _safeStringCast(similar['problemExpression'])?.trim() ?? '',
            solutionSteps: _parseSolutionSteps(similar['solutionSteps']),
          ),
        )
        .toList();
  }

  /// Safely casts any value to a string representation.
  static String? _safeStringCast(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;

    return value is List ? value.join(', ') : value.toString();
  }
}

