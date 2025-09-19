import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/chatgpt_service.dart';

final chatGptServiceProvider = Provider<ChatGptService>((ref) {
  return ChatGptService();
});
