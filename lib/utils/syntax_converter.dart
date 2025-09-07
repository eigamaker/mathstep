class SyntaxConverter {
  static String calculatorToLatex(String calculatorSyntax) {
    String latex = calculatorSyntax;
    
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
    
    // 分数の簡易記法 (a)/(b) -> \frac{a}{b}
    latex = latex.replaceAllMapped(
      RegExp(r'\(([^)]+)\)/\(([^)]+)\)'),
      (match) => '\\frac{${match.group(1)}}{${match.group(2)}}',
    );
    
    // 複素数
    latex = latex.replaceAll('i', 'i');
    latex = latex.replaceAll('pi', '\\pi');
    latex = latex.replaceAll('e', 'e');
    
    // 総和と総積
    latex = latex.replaceAllMapped(
      RegExp(r'sum\(([^,]+),([^,]+),([^)]+)\)'),
      (match) => '\\sum_{${match.group(1)}}^{${match.group(2)}} ${match.group(3)}',
    );
    
    latex = latex.replaceAllMapped(
      RegExp(r'prod\(([^,]+),([^,]+),([^)]+)\)'),
      (match) => '\\prod_{${match.group(1)}}^{${match.group(2)}} ${match.group(3)}',
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
}
