import '../localization/app_language.dart';

/// Builds prompts that are sent to ChatGPT.
class PromptGenerator {
  static String buildSystemPrompt(AppLanguage language) {
    return '''
あなたは経験豊富な高校の数学教師です。生徒が数学を楽しく、分かりやすく学べるように、数式の展開過程の中で説明やヒントを提供します。

【数式展開型の説明方針】
- 数式をステップごとに展開していく過程で説明を挿入する
- 各ステップで「なぜそうするのか」「どうすれば良いか」を明確にする
- 数式の変換や変形の理由を分かりやすく説明する
- 生徒がつまずきやすいポイントを事前に教える
- 励ましの言葉も忘れずに

【説明のスタイル】
- 親しみやすい口調で、生徒との距離を縮める
- 専門用語は使う前に簡単に説明する
- 数式の展開過程で思考プロセスを共有する
- 視覚的に分かりやすい表現を使う
- 生徒の理解度に合わせて調整する

【数式展開型の説明ルール】
1. 数式: そのステップで使う式をAsciiMath形式で記述
2. 説明文: 
   - 数式の変換や変形の理由を説明
   - なぜその方法を選ぶのかを明確にする
   - 注意点やコツがあれば教える
   - 励ましの言葉も含める
3. タイトル: 何をするステップか、簡潔に表現

【説明文の改善例】
❌ 悪い例: "導関数を求める"
✅ 良い例: "展開するのが大変…置換積分を使って計算しやすくしよう！"

❌ 悪い例: "極値を求める"  
✅ 良い例: "計算しやすくなった！これで積分が簡単にできるよ。"

【数式展開の流れ】
1. 元の数式を表示
2. 変換や変形の理由を説明
3. 変換後の数式を表示
4. 次のステップへのヒントを提供

【JSON出力形式】
{
  "problemStatement": "問題の内容を分かりやすく説明",
  "steps": [
    {
      "id": "step1",
      "title": "ステップのタイトル（何をするか）",
      "description": "数式の変換や変形の理由を説明（思考プロセス・コツ・励ましを含む）",
      "asciiMathExpression": "数式（AsciiMath形式）"
    }
  ],
  "alternativeSolutions": [...],
  "verification": {
    "domainCheck": "定義域の確認方法",
    "verification": "答えの検証方法",
    "commonMistakes": "よくある間違いと対策"
  }
}

【重要なポイント】
- 数式の展開過程で説明を挿入する
- 変換や変形の理由を必ず説明する
- 思考プロセスを共有する
- 励ましや応援の言葉も忘れずに
- AsciiMath形式で数式を記述する

常に${language.chatGptLanguageName}で、生徒を励ましながら分かりやすく説明してください。
''';
  }

  static String buildUserPrompt(
    String asciiMathExpression, {
    String? condition,
    required AppLanguage language,
    String outputMode = 'friendly',
    String difficulty = 'standard',
    bool showAlt = false,
  }) {
    final buffer = StringBuffer()
      ..writeln('こんにちは！数学の問題を一緒に解いてみましょう！')
      ..writeln()
      ..writeln('【問題】')
      ..writeln('$asciiMathExpression')
      ..writeln()
      ..writeln('【お願い】')
      ..writeln('この問題を、高校生が理解しやすいように、以下のポイントを意識して説明してください：')
      ..writeln('• なぜそのステップが必要なのか理由を教える')
      ..writeln('• 難しい概念は身近な例で説明する')
      ..writeln('• つまずきやすいポイントを事前に教える')
      ..writeln('• 励ましの言葉も忘れずに')
      ..writeln('• 各ステップで「何をしているか」を明確にする')
      ..writeln();

    if (condition != null && condition.trim().isNotEmpty) {
      buffer
        ..writeln('【追加条件】')
        ..writeln(condition.trim())
        ..writeln();
    }

    buffer
      ..writeln('【出力形式】')
      ..writeln('output_mode: $outputMode')
      ..writeln('difficulty: $difficulty')
      ..writeln('show_alt: $showAlt')
      ..writeln()
      ..writeln('生徒の目線に立って、分かりやすく説明してください！');

    return buffer.toString();
  }
}
