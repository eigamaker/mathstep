class OcrPostprocessor {
  /// Convert OCR raw text into the calculator syntax used in the app.
  /// Keeps it conservative and fixes common OCR quirks.
  static String toCalculatorSyntax(String raw) {
    String s = raw;

    // Normalize newlines/spaces
    s = s.replaceAll('\r', ' ');
    s = s.replaceAll('\n', ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Common symbol fixes
    s = s
        .replaceAll('×', '*')
        .replaceAll('·', '*')
        .replaceAll('⋅', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-') // minus
        .replaceAll('—', '-') // em dash
        .replaceAll('–', '-') // en dash
        .replaceAll('＝', '=')
        .replaceAll('∣', '|')
        .replaceAll('π', 'pi')
        .replaceAll('Π', 'pi');

    // Character misrecognition fixes
    // Fix common OCR errors where 'x' is misread as 'ae' (especially in cursive handwriting)
    s = s.replaceAll(RegExp(r'\bae\b'), 'x');
    
    // Fix other common character misrecognitions in mathematical context
    // Only apply these when they appear as standalone words (using word boundaries)
    s = s.replaceAll(RegExp(r'\bcl\b'), 'd'); // 'cl' often misread as 'd' in handwriting
    s = s.replaceAll(RegExp(r'\bco\b'), 'o'); // 'co' often misread as 'o' in handwriting

    // sqrt forms: √(expr) -> sqrt(expr), √x -> sqrt(x)
    s = s.replaceAllMapped(RegExp(r'√\s*\(([^\)]+)\)'), (m) => 'sqrt(${m.group(1)})');
    s = s.replaceAllMapped(RegExp(r'√\s*([A-Za-z0-9]+)'), (m) => 'sqrt(${m.group(1)})');

    // Absolute value: |expr| -> abs(expr)
    s = s.replaceAllMapped(RegExp(r'\|\s*([^|]+?)\s*\|'), (m) => 'abs(${m.group(1)})');

    // Functions to lowercase
    for (final fn in ['SIN', 'COS', 'TAN', 'LOG', 'LN']) {
      s = s.replaceAllMapped(RegExp('\\b$fn\\b', caseSensitive: false), (m) => fn.toLowerCase());
    }

    // Cleanup spaces around parentheses
    s = s.replaceAll(RegExp(r'\s*\(\s*'), '(');
    s = s.replaceAll(RegExp(r'\s*\)\s*'), ')');

    // Pick the most math-looking candidate if multiple are present
    final candidates = s
        .split(RegExp(r'[;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (candidates.length > 1) {
      candidates.sort((a, b) => _scoreExpression(b).compareTo(_scoreExpression(a)));
      s = candidates.first;
    }

    return s;
  }

  static int _scoreExpression(String x) {
    int sc = 0;
    if (x.contains('=')) sc += 2;
    if (RegExp(r'[a-zA-Z]').hasMatch(x)) sc += 1;
    if (RegExp(r'\d').hasMatch(x)) sc += 1;
    if (x.length > 8) sc += 1;
    return sc;
  }
}

