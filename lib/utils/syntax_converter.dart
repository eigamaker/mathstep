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
}
