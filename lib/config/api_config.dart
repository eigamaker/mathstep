import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // OpenAI API Key - .envファイルから読み込み
  static String get openaiApiKey {
    try {
      return dotenv.env['OPENAI_API_KEY'] ?? '';
    } catch (e) {
      return '';
    }
  }
  
  // API URLs
  static String get openaiApiUrl {
    try {
      return dotenv.env['OPENAI_API_URL'] ?? 'https://api.openai.com/v1/chat/completions';
    } catch (e) {
      return 'https://api.openai.com/v1/chat/completions';
    }
  }
  
  // API Settings
  static String get model {
    try {
      return dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';
    } catch (e) {
      return 'gpt-4o-mini';
    }
  }
  
  static double get temperature {
    try {
      return double.tryParse(dotenv.env['OPENAI_TEMPERATURE'] ?? '0.7') ?? 0.7;
    } catch (e) {
      return 0.7;
    }
  }
  
  static int get maxTokens {
    try {
      return int.tryParse(dotenv.env['OPENAI_MAX_TOKENS'] ?? '2000') ?? 2000;
    } catch (e) {
      return 2000;
    }
  }

  // Vision-capable model for image understanding (optional)
  static String get visionModel {
    try {
      return dotenv.env['OPENAI_VISION_MODEL'] ?? 'gpt-4o-mini';
    } catch (e) {
      return 'gpt-4o-mini';
    }
  }
  
  // 環境変数が正しく読み込まれているかチェック
  static bool get isConfigured {
    try {
      final key = openaiApiKey;
      debugPrint('ApiConfig.isConfigured: key length = ${key.length}');
      debugPrint('ApiConfig.isConfigured: key preview = ${key.isNotEmpty ? key.substring(0, key.length > 10 ? 10 : key.length) + "..." : "empty"}');
      debugPrint('ApiConfig.isConfigured: dotenv.env keys = ${dotenv.env.keys.toList()}');
      return key.isNotEmpty;
    } catch (e) {
      debugPrint('ApiConfig.isConfigured error: $e');
      return false;
    }
  }
}
