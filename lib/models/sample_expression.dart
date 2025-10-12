/// Predefined sample expressions that can be inserted into the editor.
class SampleExpression {
  const SampleExpression({required this.expression, this.condition});

  final String expression;
  final String? condition;
}

/// Collection of sample expressions.
class SampleExpressions {
  static const List<SampleExpression> _samples = [
    // 【基礎レベル】基本的な計算
    SampleExpression(expression: 'x^2 - 5x + 6 = 0'),
    SampleExpression(expression: '2x + 3 = 7'),
    SampleExpression(expression: 'sqrt(16) + sqrt(9)'),
    SampleExpression(expression: '2^3 * 2^2'),
    SampleExpression(expression: 'log_2(8)'),
    SampleExpression(expression: 'sin(30)'),
    SampleExpression(expression: 'cos(60)'),
    SampleExpression(expression: 'tan(45)'),
    
    // 【基礎レベル】一次・二次関数
    SampleExpression(expression: 'f(x) = 2x + 1'),
    SampleExpression(expression: 'f(x) = x^2 - 4x + 3'),
    SampleExpression(expression: 'f(x) = -x^2 + 6x - 5'),
    SampleExpression(expression: 'y = x^2 - 2x - 3'),
    SampleExpression(expression: 'x^2 + 2x - 3 = 0'),
    SampleExpression(expression: '2x^2 - 8x + 6 = 0'),
    
    // 【標準レベル】微分・積分の基本
    SampleExpression(expression: 'd/dx[x^3 - 3x^2 + 2x + 1]'),
    SampleExpression(expression: 'd/dx[x^2 + 4x - 1]'),
    SampleExpression(expression: 'd/dx[sin(x)]'),
    SampleExpression(expression: 'd/dx[cos(x)]'),
    SampleExpression(expression: 'd/dx[e^x]'),
    SampleExpression(expression: 'd/dx[ln(x)]'),
    SampleExpression(expression: 'integral_0^1 (x^2 + 2x + 1) dx'),
    SampleExpression(expression: 'integral_0^(pi/2) sin(x) dx'),
    SampleExpression(expression: 'integral_1^e 1/x dx'),
    
    // 【標準レベル】三角関数
    SampleExpression(expression: 'sin(30) + cos(60)'),
    SampleExpression(expression: 'sin^2(x) + cos^2(x)'),
    SampleExpression(expression: 'sin(2x) = 2sin(x)cos(x)'),
    SampleExpression(expression: 'cos(2x) = cos^2(x) - sin^2(x)'),
    SampleExpression(expression: 'sin(x + y) = sin(x)cos(y) + cos(x)sin(y)'),
    SampleExpression(expression: 'tan(x) = sin(x)/cos(x)'),
    
    // 【標準レベル】指数・対数
    SampleExpression(expression: '2^x = 8'),
    SampleExpression(expression: '3^x = 27'),
    SampleExpression(expression: 'log_2(8) + log_2(4)'),
    SampleExpression(expression: 'log_3(9) + log_3(3)'),
    SampleExpression(expression: 'e^(ln(x))'),
    SampleExpression(expression: 'log(100) + log(1000)'),
    SampleExpression(expression: '2^(x+1) = 16'),
    SampleExpression(expression: 'e^x = 5'),
    
    // 【標準レベル】関数の性質・グラフ
    SampleExpression(expression: 'f(x) = x^3 - 6x^2 + 9x + 1'),
    SampleExpression(expression: 'f(x) = x^2 - 4x + 3'),
    SampleExpression(expression: 'f(x) = sin(x) + cos(x)'),
    SampleExpression(expression: 'f(x) = e^x - x'),
    SampleExpression(expression: 'f(x) = ln(x) - x'),
    
    // 【応用レベル】積の微分・合成関数の微分
    SampleExpression(expression: 'd/dx[x^2 * sin(x)]'),
    SampleExpression(expression: 'd/dx[x * e^x]'),
    SampleExpression(expression: 'd/dx[sin(x^2)]'),
    SampleExpression(expression: 'd/dx[e^(x^2)]'),
    SampleExpression(expression: 'd/dx[ln(x^2 + 1)]'),
    SampleExpression(expression: 'd/dx[sqrt(x^2 + 1)]'),
    
    // 【応用レベル】部分積分・置換積分
    SampleExpression(expression: 'integral x * e^x dx'),
    SampleExpression(expression: 'integral x * sin(x) dx'),
    SampleExpression(expression: 'integral_0^1 x * e^x dx'),
    SampleExpression(expression: 'integral_0^(pi/2) x * sin(x) dx'),
    SampleExpression(expression: 'integral_0^2 (x^2 - 2x) dx'),
    
    // 【応用レベル】数列・極限
    SampleExpression(expression: 'sum_{k=1}^10 k'),
    SampleExpression(expression: 'sum_{k=1}^n k^2'),
    SampleExpression(expression: 'a_n = 2n + 1'),
    SampleExpression(expression: 'a_n = 3^n'),
    
    // 【入試頻出】実用的な応用問題
    SampleExpression(expression: 'f(x) = x^2 - 4x + 3', condition: 'x >= 0'),
    SampleExpression(expression: 'f(x) = x^3 - 3x^2 + 2', condition: 'x >= -1'),
    SampleExpression(expression: 'integral_0^1 (x^2 + 1) dx'),
    SampleExpression(expression: 'integral_0^pi sin^2(x) dx'),
    SampleExpression(expression: 'd/dx[ln(x^2 + 4x + 3)]'),
    
    // 【条件付き問題】定義域・値域・最大最小
    SampleExpression(expression: 'f(x) = sqrt(x^2 - 4)', condition: 'x >= 2 または x <= -2'),
    SampleExpression(expression: 'f(x) = 1/(x^2 - 1)', condition: 'x ≠ ±1'),
    SampleExpression(expression: 'f(x) = ln(x^2 - 1)', condition: 'x > 1 または x < -1'),
    SampleExpression(expression: 'f(x) = x^2 - 2x + 1', condition: 'xの最大値を求めよ'),
    SampleExpression(expression: 'f(x) = x^3 - 3x^2 + 3x - 1', condition: 'xの最小値を求めよ'),
    SampleExpression(expression: 'f(x) = sin(x) + cos(x)', condition: '0 <= x <= 2pi'),
    SampleExpression(expression: 'f(x) = e^x - x', condition: 'xの極値を求めよ'),
    SampleExpression(expression: 'f(x) = x^2 * e^(-x)', condition: 'x >= 0'),
    SampleExpression(expression: 'integral_0^1 x * sqrt(1 - x^2) dx'),
    SampleExpression(expression: 'integral_0^pi/2 sin(x) * cos(x) dx'),
    SampleExpression(expression: 'limit_{x->0} (sin(x))/x'),
    SampleExpression(expression: 'limit_{x->inf} (x^2 + 1)/(x^2 - 1)'),
    SampleExpression(expression: 'limit_{x->2} (x^2 - 4)/(x - 2)'),
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
