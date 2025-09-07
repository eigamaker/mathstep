import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // OpenAI API Key - .envファイルから読み込み
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  
  // API URLs
  static String get openaiApiUrl => dotenv.env['OPENAI_API_URL'] ?? 'https://api.openai.com/v1/chat/completions';
  
  // API Settings
  static String get model => dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';
  static double get temperature => double.tryParse(dotenv.env['OPENAI_TEMPERATURE'] ?? '0.7') ?? 0.7;
  static int get maxTokens => int.tryParse(dotenv.env['OPENAI_MAX_TOKENS'] ?? '2000') ?? 2000;

  // Vision-capable model for image understanding (optional)
  static String get visionModel => dotenv.env['OPENAI_VISION_MODEL'] ?? 'gpt-4o-mini';
  
  // 環境変数が正しく読み込まれているかチェック
  static bool get isConfigured => openaiApiKey.isNotEmpty;
}
