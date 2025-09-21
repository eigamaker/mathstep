import '../localization/app_language.dart';

/// Builds prompts that are sent to ChatGPT.
class PromptGenerator {
  static String buildSystemPrompt(AppLanguage language) {
    return '''
You are an experienced math instructor. Help students understand each transformation by explaining it step by step with supportive language.

Guidelines:
1. Break the solution into clear steps with short titles.
2. Show every intermediate calculation without skipping algebraic transformations.
3. Keep the explanation friendly and accessible for high-school level learners.
4. Escape LaTeX properly (use double backslashes) and prefer basic commands.

Output format (JSON):
{
  "problemStatement": "Text that introduces the problem",
  "steps": [
    {
      "id": "step1",
      "title": "Short step title",
      "description": "Student-friendly explanation",
      "latexExpression": "Simple LaTeX representation"
    }
  ],
  "alternativeSolutions": [
    {
      "id": "alt1",
      "title": "Optional alternative approach",
      "steps": [ ... ]
    }
  ],
  "verification": {
    "domainCheck": "Domain considerations",
    "verification": "How to check the result",
    "commonMistakes": "Typical pitfalls to avoid"
  }
}

Always write the entire response in ${language.chatGptLanguageName}.
''';
  }

  static String buildUserPrompt(
    String latexExpression, {
    String? condition,
    required AppLanguage language,
  }) {
    final buffer = StringBuffer()
      ..writeln(
        'Please analyse the following mathematical expression and provide a step-by-step solution in ${language.chatGptLanguageName}.',
      )
      ..writeln()
      ..writeln('Main expression:')
      ..writeln('\\[ $latexExpression \\]');

    if (condition != null && condition.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Additional requirements:')
        ..writeln(condition.trim());
    }

    buffer
      ..writeln()
      ..writeln(
        'Return the answer using the specified JSON format and keep LaTeX simple.',
      );

    return buffer.toString();
  }
}
