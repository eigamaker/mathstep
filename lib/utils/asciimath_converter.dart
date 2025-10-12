/// AsciiMath形式の数式変換を処理するユーティリティクラス
/// 
/// このクラスは以下の変換を提供します：
/// - 電卓記法 → AsciiMath (ChatGPT用)
/// - AsciiMath → LaTeX (UI表示用)
/// - AsciiMath → MathML (アクセシビリティ用)
/// - ChatGPT応答の正規化
class AsciiMathConverter {
  AsciiMathConverter._();

  /// 電卓記法をAsciiMath形式に変換
  /// 
  /// 例: "x^2 + 3*x + 2" → "x^2 + 3x + 2"
  static String calculatorToAsciiMath(String calculatorSyntax) {
    String asciiMath = calculatorSyntax;

    // 基本的な正規化
    asciiMath = _normalizeInput(asciiMath);

    // 分数の変換
    asciiMath = _convertFractions(asciiMath);

    // 関数の変換
    asciiMath = _convertFunctions(asciiMath);

    // 累乗の変換
    asciiMath = _convertPowers(asciiMath);

    // 根号の変換
    asciiMath = _convertRoots(asciiMath);

    // 積分の変換
    asciiMath = _convertIntegrals(asciiMath);

    // 総和・総積の変換
    asciiMath = _convertSumsAndProducts(asciiMath);

    // その他の数学記号
    asciiMath = _convertOtherSymbols(asciiMath);

    return asciiMath;
  }

  /// AsciiMath形式をLaTeX形式に変換（UI表示用）
  static String asciiMathToLatex(String asciiMath) {
    String latex = asciiMath;

    // 分数の変換: (a)/(b) → \frac{a}{b}
    latex = latex.replaceAllMapped(
      RegExp(r'\(([^)]+)\)/\(([^)]+)\)'),
      (match) => '\\frac{${match.group(1)}}{${match.group(2)}}',
    );

    // 単純な分数: a/b → \frac{a}{b} (ただし、既に\fracで囲まれていない場合)
    latex = latex.replaceAllMapped(
      RegExp(r'(\w+)/(\w+)'),
      (match) {
        final numerator = match.group(1)!;
        final denominator = match.group(2)!;
        // 既にLaTeX形式でない場合のみ変換
        if (!numerator.contains('\\') && !denominator.contains('\\')) {
          return '\\frac{$numerator}{$denominator}';
        }
        return match.group(0)!;
      },
    );

    // 平方根: sqrt(x) → \sqrt{x}
    latex = latex.replaceAllMapped(
      RegExp(r'sqrt\(([^)]+)\)'),
      (match) => '\\sqrt{${match.group(1)}}',
    );

    // n乗根: root(n, x) → \sqrt[n]{x}
    latex = latex.replaceAllMapped(
      RegExp(r'root\(([^,]+),\s*([^)]+)\)'),
      (match) => '\\sqrt[${match.group(1)}]{${match.group(2)}}',
    );

    // 積分: integral_a^b f(x) dx → \int_a^b f(x) dx (累乗変換より前に実行)
    latex = latex.replaceAllMapped(
      RegExp(r'integral_([^_\^]+)\^([^\s]+)\s+([^d]+)\s+d([a-zA-Z]+)'),
      (match) => '\\int_{${match.group(1)}}^{${match.group(2)}} ${match.group(3)} \\, d${match.group(4)}',
    );

    // 累乗: x^2 → x^{2}
    latex = latex.replaceAllMapped(
      RegExp(r'(\w+)\^(\w+)'),
      (match) => '${match.group(1)}^{${match.group(2)}}',
    );

    // 累乗: x^(y) → x^{y}
    latex = latex.replaceAllMapped(
      RegExp(r'(\w+)\^\(([^)]+)\)'),
      (match) => '${match.group(1)}^{${match.group(2)}}',
    );

    // 関数の変換（LaTeX形式に変換）
    // 三角関数はそのままにして、flutter_mathパッケージに任せる
    const functionMap = {
      'log': '\\log',
      'ln': '\\ln',
      'exp': '\\exp',
    };

    for (final entry in functionMap.entries) {
      latex = latex.replaceAllMapped(
        RegExp('${entry.key}\\(([^)]+)\\)'),
        (match) => '${entry.value}(${match.group(1)})',
      );
    }

    // 積分: int_a^b f(x) dx → \int_a^b f(x) dx
    latex = latex.replaceAllMapped(
      RegExp(r'int_([^{]+)\^([^{]+)\s+([^d]+)\s+dx'),
      (match) => '\\int_{${match.group(1)}}^{${match.group(2)}} ${match.group(3)} dx',
    );

    // 積分: int_a^{b} f(x) dx → \int_a^{b} f(x) dx
    latex = latex.replaceAllMapped(
      RegExp(r'int_([^{]+)\^\{([^}]+)\}\s+([^d]+)\s+dx'),
      (match) => '\\int_{${match.group(1)}}^{${match.group(2)}} ${match.group(3)} dx',
    );

    // 積分: int f(x) dx → \int f(x) dx
    latex = latex.replaceAllMapped(
      RegExp(r'int\s+([^d]+)\s+dx'),
      (match) => '\\int ${match.group(1)} dx',
    );

    // 積分: int(f(x), x) → \int f(x) dx
    latex = latex.replaceAllMapped(
      RegExp(r'int\(([^,]+),\s*([^)]+)\)'),
      (match) => '\\int ${match.group(1)} d${match.group(2)}',
    );

    // 積分: integral f(x) dx → \int f(x) dx (integralがそのままの場合)
    latex = latex.replaceAllMapped(
      RegExp(r'integral\s+([^d]+)\s+dx'),
      (match) => '\\int ${match.group(1)} dx',
    );

    // 微分: d/dx[f(x)] → \frac{d}{dx}[f(x)]
    latex = latex.replaceAllMapped(
      RegExp(r'd/dx\[([^\]]+)\]'),
      (match) {
        final content = match.group(1)!;
        // 微分記号内の三角関数を変換
        String convertedContent = content
            .replaceAllMapped(RegExp(r'sin\(([^)]+)\)'), (m) => '\\sin(${m.group(1)})')
            .replaceAllMapped(RegExp(r'cos\(([^)]+)\)'), (m) => '\\cos(${m.group(1)})')
            .replaceAllMapped(RegExp(r'tan\(([^)]+)\)'), (m) => '\\tan(${m.group(1)})');
        return '\\frac{d}{dx}[$convertedContent]';
      },
    );

    // 極限: limit_{x->a} f(x) → \lim_{x \to a} f(x)
    latex = latex.replaceAllMapped(
      RegExp(r'limit_\{([^}]+)->([^}]+)\}\s+([^}]+)'),
      (match) => '\\lim_{${match.group(1)} \\to ${match.group(2)}} ${match.group(3)}',
    );

    // 総和: sum(i=1, n, f(i)) → \sum_{i=1}^{n} f(i)
    latex = latex.replaceAllMapped(
      RegExp(r'sum\(([^=]+)=([^,]+),\s*([^,]+),\s*([^)]+)\)'),
      (match) => '\\sum_{${match.group(1)}=${match.group(2)}}^{${match.group(3)}} ${match.group(4)}',
    );

    // 総積: prod(i=1, n, f(i)) → \prod_{i=1}^{n} f(i)
    latex = latex.replaceAllMapped(
      RegExp(r'prod\(([^=]+)=([^,]+),\s*([^,]+),\s*([^)]+)\)'),
      (match) => '\\prod_{${match.group(1)}=${match.group(2)}}^{${match.group(3)}} ${match.group(4)}',
    );

    // 絶対値: abs(x) → |x|
    latex = latex.replaceAllMapped(
      RegExp(r'abs\(([^)]+)\)'),
      (match) => '|${match.group(1)}|',
    );

    // 数学記号の変換
    const symbolMap = {
      'pi': '\\pi',
      'inf': '\\infty',
      'alpha': '\\alpha',
      'beta': '\\beta',
      'gamma': '\\gamma',
      'delta': '\\delta',
      'epsilon': '\\epsilon',
      'theta': '\\theta',
      'lambda': '\\lambda',
      'mu': '\\mu',
      'sigma': '\\sigma',
      'phi': '\\phi',
      'omega': '\\omega',
    };

    for (final entry in symbolMap.entries) {
      latex = latex.replaceAll(entry.key, entry.value);
    }

    return latex;
  }

  /// AsciiMath形式をMathML形式に変換（アクセシビリティ用）
  static String asciiMathToMathML(String asciiMath) {
    // 基本的なMathML変換（簡易版）
    // 実際の実装では、より包括的な変換が必要
    String mathml = asciiMath;

    // 分数の変換
    mathml = mathml.replaceAllMapped(
      RegExp(r'\(([^)]+)\)/\(([^)]+)\)'),
      (match) => '<mfrac><mrow>${match.group(1)}</mrow><mrow>${match.group(2)}</mrow></mfrac>',
    );

    // 累乗の変換
    mathml = mathml.replaceAllMapped(
      RegExp(r'(\w+)\^(\w+)'),
      (match) => '<msup><mi>${match.group(1)}</mi><mi>${match.group(2)}</mi></msup>',
    );

    return '<math xmlns="http://www.w3.org/1998/Math/MathML">$mathml</math>';
  }

  /// ChatGPT応答を正規化
  /// 
  /// ChatGPTからの応答で、数式部分をAsciiMath形式に統一
  static String normalizeChatGptResponse(String response) {
    String normalized = response;

    // LaTeX形式の数式をAsciiMath形式に変換
    normalized = _convertLatexToAsciiMath(normalized);

    // 不正な文字の除去
    normalized = _cleanResponse(normalized);

    return normalized;
  }

  /// 入力の正規化
  static String _normalizeInput(String input) {
    String normalized = input;

    // 空白の正規化
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 括弧の正規化
    normalized = normalized.replaceAll('（', '(');
    normalized = normalized.replaceAll('）', ')');
    normalized = normalized.replaceAll('【', '(');
    normalized = normalized.replaceAll('】', ')');

    // 演算子の正規化
    normalized = normalized.replaceAll('×', '*');
    normalized = normalized.replaceAll('÷', '/');
    normalized = normalized.replaceAll('＝', '=');

    // 乗算記号の除去（AsciiMathでは不要、ただし関数内では保持）
    // pow(2, 3)のような関数内のカンマの前後では除去しない
    normalized = normalized.replaceAllMapped(
      RegExp(r'(\w+)\*(\w+)'),
      (match) => '${match.group(1)}${match.group(2)}',
    );
    
    // 関数内のカンマの前後の空白を正規化
    normalized = normalized.replaceAllMapped(
      RegExp(r'(\w+)\s*,\s*(\w+)'),
      (match) => '${match.group(1)},${match.group(2)}',
    );

    return normalized;
  }

  /// 分数の変換
  static String _convertFractions(String input) {
    String result = input;

    // frac{a}{b} → (a)/(b)
    result = result.replaceAllMapped(
      RegExp(r'frac\{([^}]+)\}\{([^}]+)\}'),
      (match) => '(${match.group(1)})/(${match.group(2)})',
    );

    // frac(a,b) → (a)/(b)
    result = result.replaceAllMapped(
      RegExp(r'frac\(([^,]+),([^)]+)\)'),
      (match) => '(${match.group(1)})/(${match.group(2)})',
    );

    // 単純な分数 a/b → (a)/(b) (複雑な式の場合)
    result = result.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9+\-*/^()]+)/([a-zA-Z0-9+\-*/^()]+)'),
      (match) {
        final numerator = match.group(1)!.trim();
        final denominator = match.group(2)!.trim();
        
        // 既に括弧で囲まれている場合はスキップ
        if (numerator.startsWith('(') && numerator.endsWith(')') &&
            denominator.startsWith('(') && denominator.endsWith(')')) {
          return match.group(0)!;
        }
        
        // 単純な変数や数値の場合は括弧を追加しない
        if (_isSimpleExpression(numerator) && _isSimpleExpression(denominator)) {
          return '($numerator)/($denominator)';
        }
        
        return '($numerator)/($denominator)';
      },
    );

    return result;
  }

  /// 関数の変換
  static String _convertFunctions(String input) {
    String result = input;

    // 関数名の正規化
    const functionMap = {
      'sin': 'sin',
      'cos': 'cos',
      'tan': 'tan',
      'log': 'log',
      'ln': 'ln',
      'exp': 'exp',
      'sqrt': 'sqrt',
    };

    for (final entry in functionMap.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    return result;
  }

  /// 累乗の変換
  static String _convertPowers(String input) {
    String result = input;

    // pow(a,b) → a^b
    result = result.replaceAllMapped(
      RegExp(r'pow\(([^,]+),([^)]+)\)'),
      (match) => '${match.group(1)}^${match.group(2)}',
    );

    // e^{ln(x)} → e^(ln(x))
    result = result.replaceAllMapped(
      RegExp(r'e\^\{([^}]+)\}'),
      (match) => 'e^(${match.group(1)})',
    );

    // x^{y} → x^(y)
    result = result.replaceAllMapped(
      RegExp(r'(\w+)\^\{([^}]+)\}'),
      (match) => '${match.group(1)}^(${match.group(2)})',
    );

    // x^() → x^()
    result = result.replaceAllMapped(
      RegExp(r'\^\(([^)]+)\)'),
      (match) => '^(${match.group(1)})',
    );

    return result;
  }

  /// 根号の変換
  static String _convertRoots(String input) {
    String result = input;

    // sqrt(x) → sqrt(x) (そのまま)
    // cbrt(x) → root(3, x)
    result = result.replaceAllMapped(
      RegExp(r'cbrt\(([^)]+)\)'),
      (match) => 'root(3, ${match.group(1)})',
    );

    // root(n, x) → root(n, x) (そのまま)
    // ただし、x2のような表記をx^2に変換
    result = result.replaceAllMapped(
      RegExp(r'root\(([^,]+),\s*([^)]+)\)'),
      (match) {
        final n = match.group(1)!.trim();
        final x = match.group(2)!.trim();
        // x2のような表記をx^2に変換
        final convertedX = x.replaceAllMapped(
          RegExp(r'([a-zA-Z])(\d+)'),
          (m) => '${m.group(1)}^${m.group(2)}',
        );
        return 'root($n, $convertedX)';
      },
    );

    return result;
  }

  /// 積分の変換
  static String _convertIntegrals(String input) {
    String result = input;

    // integral_a^b f(x) dx → int_a^b f(x) dx
    result = result.replaceAllMapped(
      RegExp(r'integral_([^{]+)\^([^{]+)\s+([^d]+)\s+dx'),
      (match) => 'int_${match.group(1)}^${match.group(2)} ${match.group(3)} dx',
    );

    // integral_a^{b} f(x) dx → int_a^{b} f(x) dx
    result = result.replaceAllMapped(
      RegExp(r'integral_([^{]+)\^\{([^}]+)\}\s+([^d]+)\s+dx'),
      (match) => 'int_${match.group(1)}^{${match.group(2)}} ${match.group(3)} dx',
    );

    // integral f(x) dx → int f(x) dx
    result = result.replaceAllMapped(
      RegExp(r'integral\s+([^d]+)\s+dx'),
      (match) => 'int ${match.group(1)} dx',
    );

    // integral(a, b, f(x), x) → int(f(x), x) from a to b
    result = result.replaceAllMapped(
      RegExp(r'integral\(([^,]+),([^,]+),([^,]+),([^)]+)\)'),
      (match) => 'int(${match.group(3)}, ${match.group(4)}) from ${match.group(1)} to ${match.group(2)}',
    );

    // int(f(x), x) → int(f(x), x)
    result = result.replaceAllMapped(
      RegExp(r'int\(([^,]+),([^)]+)\)'),
      (match) => 'int(${match.group(1)}, ${match.group(2)})',
    );

    return result;
  }

  /// 総和・総積の変換
  static String _convertSumsAndProducts(String input) {
    String result = input;

    // sum(i=1, n, f(i)) → sum(i=1, n, f(i))
    result = result.replaceAllMapped(
      RegExp(r'sum\(([^=]+)=([^,]+),([^,]+),([^)]+)\)'),
      (match) => 'sum(${match.group(1)}=${match.group(2)}, ${match.group(3)}, ${match.group(4)})',
    );

    // prod(i=1, n, f(i)) → prod(i=1, n, f(i))
    result = result.replaceAllMapped(
      RegExp(r'prod\(([^=]+)=([^,]+),([^,]+),([^)]+)\)'),
      (match) => 'prod(${match.group(1)}=${match.group(2)}, ${match.group(3)}, ${match.group(4)})',
    );

    return result;
  }

  /// その他の数学記号の変換
  static String _convertOtherSymbols(String input) {
    String result = input;

    const symbolMap = {
      'pi': 'pi',
      'inf': 'inf',
      'infinity': 'inf',
      '∞': 'inf',
    };

    for (final entry in symbolMap.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    return result;
  }

  /// LaTeX形式をAsciiMath形式に変換
  static String _convertLatexToAsciiMath(String input) {
    String result = input;

    // \frac{a}{b} → (a)/(b)
    result = result.replaceAllMapped(
      RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}'),
      (match) => '(${match.group(1)})/(${match.group(2)})',
    );

    // \sqrt{x} → sqrt(x)
    result = result.replaceAllMapped(
      RegExp(r'\\sqrt\{([^}]+)\}'),
      (match) => 'sqrt(${match.group(1)})',
    );

    // x^{n} → x^n
    result = result.replaceAllMapped(
      RegExp(r'(\w+)\^\{([^}]+)\}'),
      (match) => '${match.group(1)}^${match.group(2)}',
    );

    // 関数の変換
    const functionMap = {
      r'\sin': 'sin',
      r'\cos': 'cos',
      r'\tan': 'tan',
      r'\log': 'log',
      r'\ln': 'ln',
      r'\exp': 'exp',
    };

    for (final entry in functionMap.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    // 数学記号の変換
    const symbolMap = {
      r'\pi': 'pi',
      r'\infty': 'inf',
      r'\alpha': 'alpha',
      r'\beta': 'beta',
      r'\gamma': 'gamma',
      r'\delta': 'delta',
      r'\epsilon': 'epsilon',
      r'\theta': 'theta',
      r'\lambda': 'lambda',
      r'\mu': 'mu',
      r'\sigma': 'sigma',
      r'\phi': 'phi',
      r'\omega': 'omega',
    };

    for (final entry in symbolMap.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    return result;
  }

  /// 応答のクリーニング
  static String _cleanResponse(String response) {
    String cleaned = response;

    // 不正な文字の除去
    cleaned = cleaned.replaceAll(RegExp(r'[^\x00-\x7F]'), '');

    // 連続する空白の正規化
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }

  /// 単純な式かどうかを判定
  static bool _isSimpleExpression(String expression) {
    // 単一の変数、数値、または単純な関数呼び出し
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(expression) ||
           RegExp(r'^[a-zA-Z]+\([a-zA-Z0-9]+\)$').hasMatch(expression);
  }
}
