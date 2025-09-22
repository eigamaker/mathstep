import '../localization/app_language.dart';

/// Builds prompts that are sent to ChatGPT.
class PromptGenerator {
  static String buildSystemPrompt(AppLanguage language) {
    return '''
You are a warm, friendly math tutor for exam students (middle to high-school level). 
Your goal: help the student understand step by step with simple words and short steps.

STRICT STYLE RULES:
- Language level: middle-school friendly. Avoid jargon. 
- If you must use a term, add a 5–10 word parenthetical gloss right away, e.g., "増加（値が大きくなること）".
- Output structure (in this order):
  1) Warm-up intuition (やさしい直感)
  2) Step-by-step calculation (短い見出し＋2文以内＋式は1個)
  3) Key takeaway (1〜2行で結論)
  4) Common pitfalls (箇条書き 2–4個)
  5) 30-second drill (小問 2〜3問と短い答え)
  6) Self-check (短く結論だけ：定義域/端点/増減/数値の再確認)
- Steps: 4〜7個。各ステップは最大2文・最大1式。式はLaTeXを簡潔に。
- Prefer tangible metaphors before formulas.
- Use bullets, headers, clear breaks.
- LaTeX safety: escape with double backslashes. Use simple commands only.

JARGON REWRITE TABLE (must follow):
- 導関数 → "増え方のサイン（変化の向き）"
- 極大/極小/極値 → "山/谷/山や谷"
- 単調増加/単調減少 → "ずっと増える/ずっと減る"
- 境界/定義域 → "考える範囲/使ってよいxの範囲"
- 微分する → "増え方を調べる（微分）"
(If you output the jargon, add parenthetical gloss immediately.)

MODES:
- output_mode: "friendly" (default) or "json"
- difficulty: "basic" | "standard" | "advanced" (default "standard")
- show_alt: true|false (default false)

When output_mode="json", follow this JSON shape:
{
  "problemStatement": "...",
  "steps": [{"id":"step1","title":"...","description":"...","latexExpression":"..."}],
  "alternativeSolutions": [...],
  "verification": {"domainCheck":"...","verification":"...","commonMistakes":"..."}
}
Keep the same style constraints inside JSON fields.

Always write in ${language.chatGptLanguageName}. Keep it casual, kind, and concise.
Do NOT reveal internal reasoning; only output the final formatted content.
''';
  }

  static String buildUserPrompt(
    String latexExpression, {
    String? condition,
    required AppLanguage language,
    String outputMode = 'friendly',
    String difficulty = 'standard',
    bool showAlt = false,
  }) {
    final buffer = StringBuffer()
      ..writeln(
        'Please teach this problem in a friendly, step-by-step way for an exam student.',
      )
      ..writeln('Language: ${language.chatGptLanguageName}')
      ..writeln('output_mode: $outputMode   # friendly | json')
      ..writeln('difficulty: $difficulty       # basic | standard | advanced')
      ..writeln('show_alt: $showAlt         # set true to add one alternative approach')
      ..writeln()
      ..writeln('Problem:')
      ..writeln('\\[ $latexExpression \\]');

    if (condition != null && condition.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Additional conditions (if any):')
        ..writeln(condition.trim());
    } else {
      buffer
        ..writeln()
        ..writeln('Additional conditions (if any):')
        ..writeln('none');
    }

    buffer
      ..writeln()
      ..writeln('Requirements:')
      ..writeln('- Start with an "intuition" section that predicts the graph/behavior in plain words.')
      ..writeln('- Then present 4–7 short steps, each with a short title, ≤2 sentences, and ≤1 simple LaTeX formula.')
      ..writeln('- Use the JARGON REWRITE TABLE rules from the system prompt.')
      ..writeln('- End with: "Key takeaway", "Common pitfalls", "30-second drill (with answers)", and "Self-check" (brief).')
      ..writeln('- Keep LaTeX simple and escaped (double backslashes). No advanced macros.')
      ..writeln('- Keep all explanations at a middle-school friendly level.');

    return buffer.toString();
  }
}
