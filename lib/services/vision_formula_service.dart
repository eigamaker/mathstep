import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class VisionFormulaService {
  /// Uses OpenAI Vision-capable chat model to extract the main math expression
  /// from an image and convert it into the app's calculator syntax
  /// (e.g., frac(a,b), sqrt(x), cbrt(x), root(n,x), sin(x), cos(x), tan(x), ln(x), log(x), abs(x), pi, e, i, ^).
  Future<String> extractCalculatorSyntax(Uint8List imageBytes, {String? mimeType}) async {
    if (!ApiConfig.isConfigured) {
      throw Exception('OpenAI API key is not configured.');
    }

    final String base64Image = base64Encode(imageBytes);
    final String imageUrl = 'data:${mimeType ?? 'image/png'};base64,$base64Image';

    final systemPrompt = 'You are a precise OCR for mathematical expressions. '
        'Extract the single main math expression from the image and output it ONLY in the following calculator syntax: '
        'frac(a,b), sqrt(x), cbrt(x), root(n,x), sin(x), cos(x), tan(x), ln(x), log(x), abs(x), pi, e, i, ^, *, /, +, -, parentheses. '
        'Do not include any TeX/LaTeX. Do not include any explanation. Return only the expression string.';

    final userText = 'Return only the expression in the calculator syntax.';

    final uri = Uri.parse(ApiConfig.openaiApiUrl);
    final body = jsonEncode({
      'model': ApiConfig.visionModel,
      'messages': [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': userText},
            {
              'type': 'image_url',
              'image_url': {'url': imageUrl}
            }
          ]
        }
      ],
      'temperature': 0,
      'max_tokens': 500,
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.openaiApiKey}',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Vision API request failed: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['choices'][0]['message']['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw Exception('Vision API returned empty content.');
    }
    return content.trim();
  }
}

