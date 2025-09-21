import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/solution.dart';

/// JSON解析を担当するクラス
class JsonParser {
  /// APIレスポンスからSolutionオブジェクトを解析
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

  /// レスポンスからJSON文字列を抽出
  static String? _extractJsonString(String content) {
    final start = content.indexOf('{');
    final end = content.lastIndexOf('}');
    if (start == -1 || end <= start) {
      return null;
    }
    return content.substring(start, end + 1);
  }

  /// JSON文字列をクリーンアップ
  static String _cleanJsonString(String jsonString) {
    // 無効なエスケープシーケンスを修正
    return jsonString.replaceAllMapped(
      RegExp(AppConstants.multipleBackslashesPattern),
      (match) => AppConstants.replacementBackslashes,
    );
  }

  /// JSON文字列をMapに解析
  static Map<String, dynamic>? _parseJsonMap(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to parse JSON: $e');
      debugPrint('JSON string: $jsonString');
      throw Exception(AppConstants.jsonFormatError);
    }
  }

  /// JSON MapからSolutionオブジェクトを作成
  static Solution _createSolutionFromJson(Map<String, dynamic> jsonMap) {
    return Solution(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mathExpressionId: '',
      problemStatement: _safeStringCast(jsonMap['problemStatement']),
      steps: _parseSolutionSteps(jsonMap['steps']),
      alternativeSolutions: _parseAlternativeSolutions(jsonMap['alternativeSolutions']),
      verification: _parseVerification(jsonMap['verification']),
      timestamp: DateTime.now(),
    );
  }

  /// SolutionStepのリストを解析
  static List<SolutionStep> _parseSolutionSteps(dynamic stepsData) {
    if (stepsData is! List) return [];
    
    return stepsData.map((step) => SolutionStep(
      id: _safeStringCast(step['id']) ?? AppConstants.unknownId,
      title: _safeStringCast(step['title']) ?? AppConstants.untitled,
      description: _safeStringCast(step['description']) ?? AppConstants.noDescription,
      latexExpression: _safeStringCast(step['latexExpression']),
    )).toList();
  }

  /// AlternativeSolutionのリストを解析
  static List<AlternativeSolution>? _parseAlternativeSolutions(dynamic altData) {
    if (altData is! List) return null;
    
    return altData.map((alt) => AlternativeSolution(
      id: _safeStringCast(alt['id']) ?? AppConstants.unknownId,
      title: _safeStringCast(alt['title']) ?? AppConstants.untitled,
      steps: _parseSolutionSteps(alt['steps']),
    )).toList();
  }

  /// Verificationオブジェクトを解析
  static Verification? _parseVerification(dynamic verificationData) {
    if (verificationData == null) return null;
    
    return Verification(
      domainCheck: _safeStringCast(verificationData['domainCheck']),
      verification: _safeStringCast(verificationData['verification']),
      commonMistakes: _safeStringCast(verificationData['commonMistakes']),
    );
  }

  /// 安全な文字列キャスト
  static String? _safeStringCast(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List) return value.join(', ');
    if (value is Map) return value.toString();
    return value.toString();
  }
}
