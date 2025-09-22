
/// 数式テキストの処理を担当するユーティリティクラス
class MathTextProcessor {
  /// テキスト内のLaTeX記法を検出する正規表現
  static final RegExp _latexPattern = RegExp(
    r'\$([^$]+)\$|\\\[([^\]]+)\\\]|\\\(([^)]+)\\\)|\\[a-zA-Z]+\{[^}]*\}|\\[a-zA-Z]+',
    multiLine: true,
  );

  /// テキスト内の数式部分を分離して、数式とテキストの部分に分ける
  static List<MathTextSegment> parseTextWithMath(String text) {
    if (text.isEmpty) return [];

    final segments = <MathTextSegment>[];
    final matches = _latexPattern.allMatches(text);
    
    int lastEnd = 0;
    
    for (final match in matches) {
      // 数式の前のテキスト部分
      if (match.start > lastEnd) {
        final textPart = text.substring(lastEnd, match.start).trim();
        if (textPart.isNotEmpty) {
          segments.add(MathTextSegment(
            type: MathTextType.text,
            content: textPart,
          ));
        }
      }
      
      // 数式部分
      final mathContent = match.group(0)!;
      segments.add(MathTextSegment(
        type: MathTextType.math,
        content: _cleanLatex(mathContent),
      ));
      
      lastEnd = match.end;
    }
    
    // 最後のテキスト部分
    if (lastEnd < text.length) {
      final textPart = text.substring(lastEnd).trim();
      if (textPart.isNotEmpty) {
        segments.add(MathTextSegment(
          type: MathTextType.text,
          content: textPart,
        ));
      }
    }
    
    return segments;
  }

  /// LaTeX記法をクリーンアップ
  static String _cleanLatex(String latex) {
    // ドル記号を削除
    var cleaned = latex.replaceAll(RegExp(r'^\$|\$$'), '');
    // 角括弧を削除
    cleaned = cleaned.replaceAll(RegExp(r'^\\\[|\\\]$'), '');
    // 丸括弧を削除
    cleaned = cleaned.replaceAll(RegExp(r'^\\\(|\\\)$'), '');
    
    return cleaned.trim();
  }

  /// テキストが数式を含むかどうかを判定
  static bool containsMath(String text) {
    return _latexPattern.hasMatch(text);
  }

  /// 数式部分を読みやすいテキストに変換（簡易版）
  static String mathToReadableText(String mathExpression) {
    var result = mathExpression;
    
    // よく使われる数式記号の変換
    result = result.replaceAll(r'\frac{', '分数(');
    result = result.replaceAll('}{', ')/(');
    result = result.replaceAll('}', ')');
    result = result.replaceAll(r'\sqrt{', '√(');
    result = result.replaceAll(r'\pi', 'π');
    result = result.replaceAll(r'\alpha', 'α');
    result = result.replaceAll(r'\beta', 'β');
    result = result.replaceAll(r'\gamma', 'γ');
    result = result.replaceAll(r'\theta', 'θ');
    result = result.replaceAll(r'\lambda', 'λ');
    result = result.replaceAll(r'\mu', 'μ');
    result = result.replaceAll(r'\sigma', 'σ');
    result = result.replaceAll(r'\phi', 'φ');
    result = result.replaceAll(r'\omega', 'ω');
    result = result.replaceAll(r'\infty', '∞');
    result = result.replaceAll(r'\sum', 'Σ');
    result = result.replaceAll(r'\int', '∫');
    result = result.replaceAll(r'\lim', 'lim');
    result = result.replaceAll(r'\sin', 'sin');
    result = result.replaceAll(r'\cos', 'cos');
    result = result.replaceAll(r'\tan', 'tan');
    result = result.replaceAll(r'\log', 'log');
    result = result.replaceAll(r'\ln', 'ln');
    result = result.replaceAll(r'\exp', 'exp');
    result = result.replaceAll(r'\cdot', '・');
    result = result.replaceAll(r'\times', '×');
    result = result.replaceAll(r'\div', '÷');
    result = result.replaceAll(r'\pm', '±');
    result = result.replaceAll(r'\mp', '∓');
    result = result.replaceAll(r'\leq', '≤');
    result = result.replaceAll(r'\geq', '≥');
    result = result.replaceAll(r'\neq', '≠');
    result = result.replaceAll(r'\approx', '≈');
    result = result.replaceAll(r'\equiv', '≡');
    result = result.replaceAll(r'\propto', '∝');
    result = result.replaceAll(r'\in', '∈');
    result = result.replaceAll(r'\notin', '∉');
    result = result.replaceAll(r'\subset', '⊂');
    result = result.replaceAll(r'\supset', '⊃');
    result = result.replaceAll(r'\cup', '∪');
    result = result.replaceAll(r'\cap', '∩');
    result = result.replaceAll(r'\emptyset', '∅');
    result = result.replaceAll(r'\rightarrow', '→');
    result = result.replaceAll(r'\leftarrow', '←');
    result = result.replaceAll(r'\leftrightarrow', '↔');
    result = result.replaceAll(r'\Rightarrow', '⇒');
    result = result.replaceAll(r'\Leftarrow', '⇐');
    result = result.replaceAll(r'\Leftrightarrow', '⇔');
    result = result.replaceAll(r'\forall', '∀');
    result = result.replaceAll(r'\exists', '∃');
    result = result.replaceAll(r'\nabla', '∇');
    result = result.replaceAll(r'\partial', '∂');
    result = result.replaceAll(r'\Delta', 'Δ');
    
    return result;
  }
}

/// 数式テキストのセグメントタイプ
enum MathTextType {
  text,
  math,
}

/// 数式テキストのセグメント
class MathTextSegment {
  final MathTextType type;
  final String content;

  const MathTextSegment({
    required this.type,
    required this.content,
  });
}
