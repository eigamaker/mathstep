/// Lightweight helpers for splitting strings that mix prose and LaTeX.
class MathTextProcessor {
  MathTextProcessor._();

  /// Matches inline/blocked LaTeX as well as standalone commands like \sqrt{...}.
  static final RegExp _mathSegmentPattern = RegExp(
    r'(\\\[.*?\\\]|\\\(.*?\\\)|\$\$.*?\$\$|\$.*?\$|\\[a-zA-Z]+(?:\{[^}]*\})*)',
    dotAll: true,
  );

  /// Splits [text] into prose and math-aware segments while preserving spacing.
  static List<MathTextSegment> parseTextWithMath(String text) {
    if (text.isEmpty) return const [];

    final segments = <MathTextSegment>[];
    var cursor = 0;

    for (final match in _mathSegmentPattern.allMatches(text)) {
      if (match.start > cursor) {
        segments.add(
          MathTextSegment(
            type: MathTextType.text,
            content: text.substring(cursor, match.start),
          ),
        );
      }

      final rawMath = match.group(0) ?? '';
      if (rawMath.isNotEmpty) {
        segments.add(
          MathTextSegment(
            type: MathTextType.math,
            content: _cleanLatex(rawMath),
          ),
        );
      }

      cursor = match.end;
    }

    if (cursor < text.length) {
      segments.add(
        MathTextSegment(
          type: MathTextType.text,
          content: text.substring(cursor),
        ),
      );
    }

    return segments;
  }

  /// Returns true when [text] appears to contain LaTeX commands or delimiters.
  static bool containsMath(String text) {
    if (text.isEmpty) return false;
    return _mathSegmentPattern.hasMatch(text);
  }

  /// Converts a small subset of LaTeX into a readable, plain-text approximation.
  static String mathToReadableText(String mathExpression) {
    var result = mathExpression;

    result = result.replaceAllMapped(
      RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}'),
      (match) => '(${match[1]})/(${match[2]})',
    );

    result = result.replaceAllMapped(
      RegExp(r'\\sqrt\{([^}]+)\}'),
      (match) => 'sqrt(${match[1]})',
    );

    const replacements = <String, String>{
      r'\pi': 'pi',
      r'\cdot': '*',
      r'\times': 'x',
      r'\div': '/',
      r'\pm': '+/-',
      r'\mp': '-/+',
      r'\leq': '<=',
      r'\geq': '>=',
      r'\neq': '!=',
      r'\approx': '~',
      r'\equiv': '≡',
      r'\propto': 'proportional',
      r'\infty': 'infinity',
      r'\sin': 'sin',
      r'\cos': 'cos',
      r'\tan': 'tan',
      r'\log': 'log',
      r'\ln': 'ln',
      r'\exp': 'exp',
      r'\left': '',
      r'\right': '',
      r'\,': ' ',
    };

    for (final entry in replacements.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    result = result.replaceAll('^', ' ^ ');
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    return result.trim();
  }

  static String _cleanLatex(String raw) {
    var value = raw.trim();

    if (value.startsWith(r'\[') && value.endsWith(r'\]')) {
      return value.substring(2, value.length - 2).trim();
    }

    if (value.startsWith(r'\(') && value.endsWith(r'\)')) {
      return value.substring(2, value.length - 2).trim();
    }

    if (value.startsWith(r'$$') && value.endsWith(r'$$')) {
      return value.substring(2, value.length - 2).trim();
    }

    if (value.startsWith(r'$') && value.endsWith(r'$') && value.length >= 2) {
      return value.substring(1, value.length - 1).trim();
    }

    return value;
  }
}

enum MathTextType { text, math }

class MathTextSegment {
  const MathTextSegment({required this.type, required this.content});

  final MathTextType type;
  final String content;
}
