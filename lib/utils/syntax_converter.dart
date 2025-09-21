class SyntaxConverter {
  static String calculatorToLatex(String calculatorSyntax) {
    String latex = calculatorSyntax;

    latex = _convertGenericFractions(latex);

    
    // 基本的な変換ルール
    latex = latex.replaceAllMapped(
      RegExp(r'frac\(([^,]+),([^)]+)\)'),
      (match) => '\\frac{${match.group(1)}}{${match.group(2)}}',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'sqrt\(([^)]+)\)'),
      (match) => '\\sqrt{${match.group(1)}}',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'cbrt\(([^)]+)\)'),
      (match) => '\\sqrt[3]{${match.group(1)}}',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'root\(([^,]+),([^)]+)\)'),
      (match) => '\\sqrt[${match.group(1)}]{${match.group(2)}}',
    );
    
    // 関数の変換
    latex = latex.replaceAllMapped(
      RegExp(r'sin\(([^)]+)\)'),
      (match) => '\\sin(${match.group(1)})',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'cos\(([^)]+)\)'),
      (match) => '\\cos(${match.group(1)})',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'tan\(([^)]+)\)'),
      (match) => '\\tan(${match.group(1)})',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'ln\(([^)]+)\)'),
      (match) => '\\ln(${match.group(1)})',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'log\(([^)]+)\)'),
      (match) => '\\log(${match.group(1)})',
    );
    
    // pow()関数の変換（括弧付きべき乗）
    latex = latex.replaceAllMapped(
      RegExp(r'pow\(([^,]+),([^)]+)\)'),
      (match) => '${match.group(1)}^{${match.group(2)}}',
    );
    
    // x^()形式のべき乗の変換
    latex = latex.replaceAllMapped(
      RegExp(r'\^\(([^)]+)\)'),
      (match) => '^{${match.group(1)}}',
    );
    
    // 累乗の変換
    latex = latex.replaceAllMapped(
      RegExp(r'\^(\d+)'),
      (match) => '^{${match.group(1)}}',
    );
    
    // 絶対値
    latex = latex.replaceAllMapped(
      RegExp(r'abs\(([^)]+)\)'),
      (match) => '|${match.group(1)}|',
    );
    
    // 複素数
    latex = latex.replaceAll('i', 'i');
    latex = latex.replaceAll('pi', '\\pi');
    latex = latex.replaceAll('e', 'e');
    
    // 総和と総積（分数より先に変換）
    latex = latex.replaceAllMapped(
      RegExp(r'sum\(([^,]+),([^,]+),([^)]+)\)'),
      (match) => '\\sum_{${match.group(1)}}^{${match.group(2)}} ${match.group(3)}',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'prod\(([^,]+),([^,]+),([^)]+)\)'),
      (match) => '\\prod_{${match.group(1)}}^{${match.group(2)}} ${match.group(3)}',
    );
    
    // 単純なΣ記号の変換 (sum(n=1,n,expression))
    latex = latex.replaceAllMapped(
      RegExp(r'sum\(([a-zA-Z]+)=([^,]+),([^,]+),([^)]+)\)'),
      (match) => '\\sum_{${match.group(1)}=${match.group(2)}}^{${match.group(3)}} ${match.group(4)}',
    );
    
    // 単純なΠ記号の変換 (prod(n=1,n,expression))
    latex = latex.replaceAllMapped(
      RegExp(r'prod\(([a-zA-Z]+)=([^,]+),([^,]+),([^)]+)\)'),
      (match) => '\\prod_{${match.group(1)}=${match.group(2)}}^{${match.group(3)}} ${match.group(4)}',
    );
    
    // 分数の簡易記法 (a)/(b) -> \frac{a}{b}
    latex = latex.replaceAllMapped(
      RegExp(r'\(([^)]+)\)/\(([^)]+)\)'),
      (match) => '\\frac{${match.group(1)}}{${match.group(2)}}',
    );
    
    // 単純な分数 a/b -> \frac{a}{b} (括弧なし)
    latex = latex.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)\s*/\s*(\d+(?:\.\d+)?)'),
      (match) => '\\frac{${match.group(1)}}{${match.group(2)}}',
    );
    
    // 変数を含む分数 a/b -> \frac{a}{b}
    latex = latex.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9+\-*/^()]+)\s*/\s*([a-zA-Z0-9+\-*/^()]+)'),
      (match) {
        final numerator = match.group(1)?.trim() ?? '';
        final denominator = match.group(2)?.trim() ?? '';
        // 既に\fracで囲まれている場合はスキップ
        if (numerator.contains('\\frac') || denominator.contains('\\frac')) {
          return match.group(0) ?? '';
        }
        
        // 分数内のΣ記号を適切に処理
        String processedNumerator = _processSumInFraction(numerator);
        String processedDenominator = _processSumInFraction(denominator);
        
        return '\\frac{$processedNumerator}{$processedDenominator}';
      },
    );
    
    // 順列と組み合わせ
    latex = latex.replaceAllMapped(
      RegExp(r'(\w+)Pr\(([^)]+)\)'),
      (match) => 'P_{${match.group(2)}}^{${match.group(1)}}',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'(\w+)Cr\(([^)]+)\)'),
      (match) => 'C_{${match.group(2)}}^{${match.group(1)}}',
    );
    
    // 階乗
    latex = latex.replaceAllMapped(
      RegExp(r'(\w+)!'),
      (match) => '${match.group(1)}!',
    );
    
    // n!記法の変換
    latex = latex.replaceAll('n!', 'n!');
    
    // 複素数の実部・虚部
    latex = latex.replaceAllMapped(
      RegExp(r'Re\(([^)]+)\)'),
      (match) => '\\Re(${match.group(1)})',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'Im\(([^)]+)\)'),
      (match) => '\\Im(${match.group(1)})',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'conj\(([^)]+)\)'),
      (match) => '\\overline{${match.group(1)}}',
    );
    
    // --- Calculus extensions (Math III) ---
    String _inf(String s) => s.replaceAll('inf', '\\infty').replaceAll('∞', '\\infty');

    // Definite integral: integral(lower,upper,expr,var) or int(lower,upper,expr,var)
    latex = latex.replaceAllMapped(
      RegExp(r'integral\(([^,]+),([^,]+),([^,]+),([^)]+)\)'),
      (m) => '\\int_{${_inf(m.group(1)!.trim())}}^{${_inf(m.group(2)!.trim())}} ${m.group(3)!.trim()} \\, d${m.group(4)!.trim()}',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'int\(([^,]+),([^,]+),([^,]+),([^)]+)\)'),
      (m) => '\\int_{${_inf(m.group(1)!.trim())}}^{${_inf(m.group(2)!.trim())}} ${m.group(3)!.trim()} \\, d${m.group(4)!.trim()}',
    );

    // Indefinite integral: integral(expr,var) or int(expr,var)
    latex = latex.replaceAllMapped(
      RegExp(r'(?:integral|int)\(([^,]+),([^)]+)\)'),
      (m) => '\\int ${m.group(1)!.trim()} \\, d${m.group(2)!.trim()}',
    );
    
    // より簡潔な積分記法: ∫[a,b] f(x) dx
    latex = latex.replaceAllMapped(
      RegExp(r'∫\[([^,]+),([^\]]+)\]\s*([^d]+)\s*d([a-zA-Z]+)'),
      (m) => '\\int_{${_inf(m.group(1)!.trim())}}^{${_inf(m.group(2)!.trim())}} ${m.group(3)!.trim()} \\, d${m.group(4)!.trim()}',
    );
    
    // 単純な積分記法: ∫ f(x) dx
    latex = latex.replaceAllMapped(
      RegExp(r'∫\s*([^d]+)\s*d([a-zA-Z]+)'),
      (m) => '\\int ${m.group(1)!.trim()} \\, d${m.group(2)!.trim()}',
    );

    // Derivatives: diff(expr,var), diff2(expr,var), partial(expr,var)
    latex = latex.replaceAllMapped(
      RegExp(r'diff2\(([^,]+),([^)]+)\)'),
      (m) => '\\frac{d^{2}}{d ${m.group(2)!.trim()}^{2}} ${m.group(1)!.trim()}',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'diff\(([^,]+),([^)]+)\)'),
      (m) => '\\frac{d}{d ${m.group(2)!.trim()}} ${m.group(1)!.trim()}',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'partial\(([^,]+),([^)]+)\)'),
      (m) => '\\frac{\\partial}{\\partial ${m.group(2)!.trim()}} ${m.group(1)!.trim()}',
    );

    // Limit: limit(var,value,expr) or lim(var,value,expr)
    latex = latex.replaceAllMapped(
      RegExp(r'(?:limit|lim)\(([^,]+),([^,]+),([^)]+)\)'),
      (m) => '\\lim_{${m.group(1)!.trim()} \\to ${_inf(m.group(2)!.trim())}} ${m.group(3)!.trim()}',
    );

    // Sum/Prod with index variable
    latex = latex.replaceAllMapped(
      RegExp(r'sum\(\s*([a-zA-Z]\\w*)\s*=\s*([^,]+),([^,]+),([^)]+)\)'),
      (m) => '\\sum_{${m.group(1)!.trim()}=${m.group(2)!.trim()}}^{${m.group(3)!.trim()}} ${m.group(4)!.trim()}',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'sum\(\s*([a-zA-Z]\\w*),([^,]+),([^,]+),([^)]+)\)'),
      (m) => '\\sum_{${m.group(1)!.trim()}=${m.group(2)!.trim()}}^{${m.group(3)!.trim()}} ${m.group(4)!.trim()}',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'prod\(\s*([a-zA-Z]\\w*)\s*=\s*([^,]+),([^,]+),([^)]+)\)'),
      (m) => '\\prod_{${m.group(1)!.trim()}=${m.group(2)!.trim()}}^{${m.group(3)!.trim()}} ${m.group(4)!.trim()}',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'prod\(\s*([a-zA-Z]\\w*),([^,]+),([^,]+),([^)]+)\)'),
      (m) => '\\prod_{${m.group(1)!.trim()}=${m.group(2)!.trim()}}^{${m.group(3)!.trim()}} ${m.group(4)!.trim()}',
    );

    // Piecewise and matrix
    latex = _convertCases(latex);
    latex = _convertMatrix(latex);

    return latex;
  }
  
  static String normalizeCalculatorSyntax(String input) {
    String normalized = input;
    
    // 空白を削除
    normalized = normalized.replaceAll(' ', '');
    
    // 括弧の正規化
    normalized = normalized.replaceAll('（', '(');
    normalized = normalized.replaceAll('）', ')');
    normalized = normalized.replaceAll('【', '(');
    normalized = normalized.replaceAll('】', ')');
    
    // 演算子の正規化
    normalized = normalized.replaceAll('×', '*');
    normalized = normalized.replaceAll('÷', '/');
    normalized = normalized.replaceAll('＝', '=');
    
    return normalized;
  }

  // --- Helpers: piecewise and matrix ---
  static String _convertCases(String s) {
    const head = 'cases(';
    int idx = 0;
    while (true) {
      idx = s.indexOf(head, idx);
      if (idx == -1) break;
      final start = idx + head.length;
      final end = _findMatchingParen(s, start - 1);
      if (end == -1) break;
      final inner = s.substring(start, end);
      final latex = _casesInnerToLatex(inner);
      s = s.substring(0, idx) + latex + s.substring(end + 1);
      idx += latex.length;
    }
    return s;
  }

  static String _casesInnerToLatex(String inner) {
    final items = _splitTopLevelGroups(inner);
    final lines = <String>[];
    for (final g in items) {
      final pair = _splitTopLevelCommas(_stripParens(g));
      if (pair.length >= 2) {
        final expr = pair[0].trim();
        final condRaw = pair[1].trim();
        final cond = (condRaw.toLowerCase() == 'otherwise' || condRaw.toLowerCase() == 'else')
            ? '\\text{otherwise}'
            : '\\text{if } ' + condRaw;
        lines.add('$expr & $cond');
      }
    }
    if (lines.isEmpty) return inner; // fallback
    return '\\begin{cases} ' + lines.join(' \\ ') + ' \\end{cases}';
  }

  static String _convertMatrix(String s) {
    const head = 'matrix(';
    int idx = 0;
    while (true) {
      idx = s.indexOf(head, idx);
      if (idx == -1) break;
      final start = idx + head.length;
      final end = _findMatchingParen(s, start - 1);
      if (end == -1) break;
      final inner = s.substring(start, end);
      final latex = _matrixInnerToLatex(inner);
      s = s.substring(0, idx) + latex + s.substring(end + 1);
      idx += latex.length;
    }
    return s;
  }

  static String _matrixInnerToLatex(String inner) {
    final rows = _splitTopLevelGroups(inner).map((g) => _stripParens(g)).toList();
    if (rows.isEmpty) return inner;
    final rowLatex = rows.map((r) => _splitTopLevelCommas(r).map((e) => e.trim()).join(' & ')).join(' \\ ');
    return '\\begin{bmatrix} ' + rowLatex + ' \\end{bmatrix}';
  }

  static int _findMatchingParen(String s, int openIndex) {
    int depth = 0;
    for (int i = openIndex; i < s.length; i++) {
      final c = s[i];
      if (c == '(') depth++;
      if (c == ')') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }

  static List<String> _splitTopLevelGroups(String s) {
    final res = <String>[];
    int depth = 0;
    int start = -1;
    for (int i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '(') {
        if (depth == 0) start = i;
        depth++;
      } else if (c == ')') {
        depth--;
        if (depth == 0 && start >= 0) {
          res.add(s.substring(start, i + 1));
        }
      }
    }
    return res;
  }

  static List<String> _splitTopLevelCommas(String s) {
    final res = <String>[];
    int depth = 0;
    int last = 0;
    for (int i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '(') depth++;
      if (c == ')') depth--;
      if (c == ',' && depth == 0) {
        res.add(s.substring(last, i));
        last = i + 1;
      }
    }
    res.add(s.substring(last));
    return res;
  }

  static String _stripParens(String s) {
    String t = s.trim();
    if (t.startsWith('(') && t.endsWith(')')) {
      return t.substring(1, t.length - 1);
    }
    return t;
  }

  // 分数内のΣ記号を適切に処理するヘルパーメソッド
  static String _convertGenericFractions(String input) {
    if (!input.contains('/')) {
      return input;
    }

    final buffer = StringBuffer();
    var index = 0;
    while (index < input.length) {
      final slash = input.indexOf('/', index);
      if (slash == -1) {
        buffer.write(input.substring(index));
        break;
      }

      final left = _extractFractionLeftOperand(input, slash - 1);
      final right = _extractFractionRightOperand(input, slash + 1);

      if (left == null || right == null || left.start < index) {
        buffer.write(input.substring(index, slash + 1));
        index = slash + 1;
        continue;
      }

      var numerator = input.substring(left.start, left.end).trim();
      var denominator = input.substring(right.start, right.end).trim();

      if (numerator.isEmpty || denominator.isEmpty) {
        buffer.write(input.substring(index, slash + 1));
        index = slash + 1;
        continue;
      }

      numerator = _normalizeFractionOperand(numerator);
      denominator = _normalizeFractionOperand(denominator);

      buffer.write(input.substring(index, left.start));
      buffer.write('\\frac{$numerator}{$denominator}');
      index = right.end;
    }
    return buffer.toString();
  }

  static String _normalizeFractionOperand(String value) {
    if (value.startsWith('- ')) {
      return '-${value.substring(2).trimLeft()}';
    }
    if (value.startsWith('+ ')) {
      return value.substring(2).trimLeft();
    }
    return value;
  }

  static _Span? _extractFractionLeftOperand(String input, int index) {
    var i = _skipWhitespaceBackward(input, index);
    if (i < 0) {
      return null;
    }

    final end = i + 1;
    final code = input.codeUnitAt(i);

    int start;

    if (code == _rParen) {
      final openIndex = _findMatchingOpenParenBackward(input, i);
      if (openIndex == -1) {
        return null;
      }
      start = openIndex;
      var j = openIndex - 1;
      while (j >= 0 && _isIdentifierChar(input, j)) {
        j--;
      }
      start = j + 1;
    } else if (_isIdentifierChar(input, i)) {
      var j = i;
      while (j >= 0 && _isIdentifierChar(input, j)) {
        j--;
      }
      start = j + 1;
    } else {
      return null;
    }

    final signIndex = _skipWhitespaceBackward(input, start - 1);
    if (signIndex >= 0 && input.codeUnitAt(signIndex) == _minus) {
      final prev = _skipWhitespaceBackward(input, signIndex - 1);
      final prevCode = prev >= 0 ? input.codeUnitAt(prev) : null;
      if (_isOperatorLike(prevCode)) {
        start = signIndex;
      }
    }

    return _Span(start, end);
  }

  static _Span? _extractFractionRightOperand(String input, int index) {
    var i = _skipWhitespaceForward(input, index);
    if (i >= input.length) {
      return null;
    }

    var start = i;
    var code = input.codeUnitAt(i);

    if (code == _plus || code == _minus) {
      final signStart = start;
      i = _skipWhitespaceForward(input, i + 1);
      if (i >= input.length) {
        return null;
      }
      start = signStart;
      code = input.codeUnitAt(i);
    }

    int end;

    if (code == _lParen) {
      final closeIndex = _findMatchingCloseParen(input, i);
      if (closeIndex == -1) {
        return null;
      }
      end = closeIndex + 1;
    } else if (_isIdentifierChar(input, i)) {
      var j = i;
      while (j < input.length && _isIdentifierChar(input, j)) {
        j++;
      }
      if (j < input.length && input.codeUnitAt(j) == _lParen) {
        final closeIndex = _findMatchingCloseParen(input, j);
        if (closeIndex == -1) {
          return null;
        }
        end = closeIndex + 1;
      } else {
        end = j;
      }
    } else {
      return null;
    }

    return _Span(start, end);
  }

  static int _skipWhitespaceBackward(String input, int index) {
    var i = index;
    while (i >= 0) {
      final code = input.codeUnitAt(i);
      if (!_isWhitespace(code)) {
        return i;
      }
      i--;
    }
    return -1;
  }

  static int _skipWhitespaceForward(String input, int index) {
    var i = index;
    while (i < input.length) {
      final code = input.codeUnitAt(i);
      if (!_isWhitespace(code)) {
        return i;
      }
      i++;
    }
    return input.length;
  }

  static bool _isWhitespace(int code) {
    return code == 32 || code == 9 || code == 10 || code == 13;
  }

  static bool _isIdentifierChar(String input, int index) {
    final code = input.codeUnitAt(index);
    if ((code >= 48 && code <= 57) || (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122)) {
      return true;
    }
    return code == 95 || code == 46 || code == 39;
  }

  static bool _isOperatorLike(int? code) {
    if (code == null) {
      return true;
    }
    return code == _plus ||
        code == _minus ||
        code == _asterisk ||
        code == _slash ||
        code == _caret ||
        code == _comma ||
        code == _lParen ||
        code == _equals;
  }

  static int _findMatchingOpenParenBackward(String input, int closeIndex) {
    var depth = 0;
    for (var i = closeIndex; i >= 0; i--) {
      final code = input.codeUnitAt(i);
      if (code == _rParen) {
        depth++;
      } else if (code == _lParen) {
        depth--;
        if (depth == 0) {
          return i;
        }
      }
    }
    return -1;
  }

  static int _findMatchingCloseParen(String input, int openIndex) {
    var depth = 0;
    for (var i = openIndex; i < input.length; i++) {
      final code = input.codeUnitAt(i);
      if (code == _lParen) {
        depth++;
      } else if (code == _rParen) {
        depth--;
        if (depth == 0) {
          return i;
        }
      }
    }
    return -1;
  }

  static const int _plus = 43;
  static const int _minus = 45;
  static const int _asterisk = 42;
  static const int _slash = 47;
  static const int _caret = 94;
  static const int _comma = 44;
  static const int _equals = 61;
  static const int _lParen = 40;
  static const int _rParen = 41;

  static String _processSumInFraction(String expression) {
    // 既にLaTeX形式のΣ記号が含まれている場合はそのまま返す
    if (expression.contains('\\sum')) {
      return expression;
    }
    
    // sum()形式のΣ記号をLaTeX形式に変換
    String result = expression;
    
    // sum(n=1,10,expression) -> \displaystyle\sum_{n=1}^{10} expression
    result = result.replaceAllMapped(
      RegExp(r'sum\(([a-zA-Z]+)=([^,]+),([^,]+),([^)]+)\)'),
      (match) => '\\displaystyle\\sum_{${match.group(1)}=${match.group(2)}}^{${match.group(3)}} ${match.group(4)}',
    );
    
    // sum(1,10,expression) -> \displaystyle\sum_{1}^{10} expression
    result = result.replaceAllMapped(
      RegExp(r'sum\(([^,]+),([^,]+),([^)]+)\)'),
      (match) => '\\displaystyle\\sum_{${match.group(1)}}^{${match.group(2)}} ${match.group(3)}',
    );
    
    return result;
  }
}

class _Span {
  final int start;
  final int end;

  const _Span(this.start, this.end);
}
