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
      if (jsonString == null) return null;

      final cleanedJsonString = _cleanJsonString(jsonString);
      final jsonMap = _parseJsonMap(cleanedJsonString);
      if (jsonMap == null) return null;

      return _createSolutionFromJson(jsonMap);
    } catch (error, stackTrace) {
      debugPrint('Failed to parse solution response: $error\n$stackTrace');
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

  /// Normalises invalid escape sequences inside the JSON payload.
  static String _cleanJsonString(String jsonString) {
    return jsonString.replaceAllMapped(
      RegExp(AppConstants.multipleBackslashesPattern),
      (match) => AppConstants.replacementBackslashes,
    );
  }

  /// Decodes a JSON string to a map.
  static Map<String, dynamic>? _parseJsonMap(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to parse JSON: $e');
      debugPrint('JSON string: $jsonString');
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
      alternativeSolutions: _parseAlternativeSolutions(
        jsonMap['alternativeSolutions'],
      ),
      verification: _parseVerification(jsonMap['verification']),
      timestamp: DateTime.now(),
    );
  }

  /// Parses the list of solution steps.
  static List<SolutionStep> _parseSolutionSteps(dynamic stepsData) {
    if (stepsData is! List) return [];

    return stepsData
        .map(
          (step) => SolutionStep(
            id: _safeStringCast(step['id']) ?? AppConstants.unknownId,
            title: _safeStringCast(step['title'])?.trim() ?? '',
            description: _safeStringCast(step['description'])?.trim() ?? '',
            latexExpression: _safeStringCast(step['latexExpression']),
          ),
        )
        .toList();
  }

  /// Parses any alternative solutions provided by the API.
  static List<AlternativeSolution>? _parseAlternativeSolutions(
    dynamic altData,
  ) {
    if (altData is! List) return null;

    return altData
        .map(
          (alt) => AlternativeSolution(
            id: _safeStringCast(alt['id']) ?? AppConstants.unknownId,
            title: _safeStringCast(alt['title'])?.trim() ?? '',
            steps: _parseSolutionSteps(alt['steps']),
          ),
        )
        .toList();
  }

  /// Parses the verification block if present.
  static Verification? _parseVerification(dynamic verificationData) {
    if (verificationData == null) return null;

    return Verification(
      domainCheck: _safeStringCast(verificationData['domainCheck']),
      verification: _safeStringCast(verificationData['verification']),
      commonMistakes: _safeStringCast(verificationData['commonMistakes']),
    );
  }

  /// Safely casts any value to a string representation.
  static String? _safeStringCast(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List) return value.join(', ');
    if (value is Map) return value.toString();
    return value.toString();
  }
}
