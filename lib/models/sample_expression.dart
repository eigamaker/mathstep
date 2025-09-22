/// Predefined sample expressions that can be inserted into the editor.
class SampleExpression {
  const SampleExpression({required this.expression, this.condition});

  final String expression;
  final String? condition;
}

/// Collection of sample expressions.
class SampleExpressions {
  static const List<SampleExpression> _samples = [
    SampleExpression(expression: 'd/dx[sin(2x) * cos(3x)]'),
    SampleExpression(expression: 'integral_0^{pi/2} sin^3(x) * cos^2(x) dx'),
    SampleExpression(expression: 'integral_1^{e} x * ln(x) dx'),
    SampleExpression(expression: 'integral_0^{1} x^2 * e^x dx'),
    SampleExpression(expression: 'integral_0^{2} 1/(x^2 + 4) dx'),
    SampleExpression(expression: 'limit_{x->0} (sin x - x) / x^3'),
    SampleExpression(expression: 'limit_{x->0} (1 + x)^(1/x)'),
    SampleExpression(
      expression: 'sum_{k=1}^{n} k^2 * 2^k',
      condition: 'n in N',
    ),
    SampleExpression(expression: 'sum_{k=0}^{inf} x^k / k!'),
    SampleExpression(expression: 'f(x) = x^3 - 3x^2 + 2x'),
    SampleExpression(expression: 'f(x) = x^2 * e^{-x}', condition: 'x >= 0'),
    SampleExpression(expression: 'y = x^3 - 6x^2 + 9x'),
    SampleExpression(
      expression: '|a + b|^2',
      condition: '|a| = 3, |b| = 4, dot(a,b) = 6',
    ),
    SampleExpression(expression: 'distance((1,2,3), 2x + 3y + 6z = 1)'),
    SampleExpression(expression: '(1 + i)^8'),
    SampleExpression(expression: 'z^4 + 16 = 0'),
    SampleExpression(expression: '|z - 1| = |z - i|'),
    SampleExpression(expression: 'det [[1,2,3],[0,4,5],[1,0,6]]'),
    SampleExpression(expression: 'sin(75 deg) + sin(15 deg)'),
    SampleExpression(expression: 'log_2(8) + log_3(27) - log_4(16)'),
    SampleExpression(expression: '2^x + 2^{-x} = 3'),
  ];

  /// Gets a pseudo-random sample expression.
  static SampleExpression getRandom() {
    final index = DateTime.now().millisecondsSinceEpoch % _samples.length;
    return _samples[index];
  }

  /// Returns all registered sample expressions.
  static List<SampleExpression> getAll() {
    return List.unmodifiable(_samples);
  }

  /// Total number of sample expressions.
  static int get count => _samples.length;
}
